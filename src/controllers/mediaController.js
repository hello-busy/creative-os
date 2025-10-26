const Media = require('../models/Media');

// Upload media (placeholder - actual file upload would need multer or similar)
exports.createMedia = async (req, res) => {
  try {
    const { title, description, type, fileUrl, fileSize, mimeType, tags, isPublic } = req.body;

    const media = new Media({
      title,
      description,
      type,
      fileUrl,
      fileSize,
      mimeType,
      tags: tags || [],
      isPublic: isPublic || false,
      owner: req.user._id,
    });

    await media.save();
    await media.populate('owner', 'username email');

    res.status(201).json({ media });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Get media library
exports.getMedia = async (req, res) => {
  try {
    const { type, search } = req.query;
    const query = { owner: req.user._id };

    if (type) query.type = type;
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { tags: { $regex: search, $options: 'i' } },
      ];
    }

    const media = await Media.find(query)
      .populate('owner', 'username email')
      .sort({ uploadedAt: -1 });

    res.json({ media });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get media by ID
exports.getMediaById = async (req, res) => {
  try {
    const media = await Media.findById(req.params.id)
      .populate('owner', 'username email')
      .populate('projects', 'title');

    if (!media) {
      return res.status(404).json({ message: 'Media not found' });
    }

    // Check access
    if (!media.isPublic && !media.owner.equals(req.user._id)) {
      return res.status(403).json({ message: 'Access denied' });
    }

    res.json({ media });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Update media
exports.updateMedia = async (req, res) => {
  try {
    const media = await Media.findById(req.params.id);

    if (!media) {
      return res.status(404).json({ message: 'Media not found' });
    }

    if (!media.owner.equals(req.user._id)) {
      return res.status(403).json({ message: 'Only owner can update media' });
    }

    const updates = ['title', 'description', 'tags', 'isPublic'];
    updates.forEach(field => {
      if (req.body[field] !== undefined) {
        media[field] = req.body[field];
      }
    });

    await media.save();
    res.json({ media });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Delete media
exports.deleteMedia = async (req, res) => {
  try {
    const media = await Media.findById(req.params.id);

    if (!media) {
      return res.status(404).json({ message: 'Media not found' });
    }

    if (!media.owner.equals(req.user._id)) {
      return res.status(403).json({ message: 'Only owner can delete media' });
    }

    await media.deleteOne();
    res.json({ message: 'Media deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
