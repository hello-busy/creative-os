const Template = require('../models/Template');

// Create template
exports.createTemplate = async (req, res) => {
  try {
    const { title, description, category, thumbnail, previewUrl, structure, tags } = req.body;

    const template = new Template({
      title,
      description,
      category,
      thumbnail,
      previewUrl,
      structure,
      tags: tags || [],
      creator: req.user._id,
    });

    await template.save();
    await template.populate('creator', 'username email');

    res.status(201).json({ template });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Get templates
exports.getTemplates = async (req, res) => {
  try {
    const { category, featured, search } = req.query;
    const query = {};

    if (category) query.category = category;
    if (featured === 'true') query.isFeatured = true;
    if (search) {
      query.$or = [
        { title: { $regex: search, $options: 'i' } },
        { tags: { $regex: search, $options: 'i' } },
      ];
    }

    const templates = await Template.find(query)
      .populate('creator', 'username email')
      .sort({ isFeatured: -1, 'rating.average': -1, usageCount: -1 });

    res.json({ templates });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get template by ID
exports.getTemplateById = async (req, res) => {
  try {
    const template = await Template.findById(req.params.id)
      .populate('creator', 'username email');

    if (!template) {
      return res.status(404).json({ message: 'Template not found' });
    }

    res.json({ template });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Use template (increment usage count)
exports.useTemplate = async (req, res) => {
  try {
    const template = await Template.findById(req.params.id);

    if (!template) {
      return res.status(404).json({ message: 'Template not found' });
    }

    template.usageCount += 1;
    await template.save();

    res.json({ template });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Rate template
exports.rateTemplate = async (req, res) => {
  try {
    const { rating } = req.body;

    if (rating < 1 || rating > 5) {
      return res.status(400).json({ message: 'Rating must be between 1 and 5' });
    }

    const template = await Template.findById(req.params.id);

    if (!template) {
      return res.status(404).json({ message: 'Template not found' });
    }

    // Simple rating calculation
    const totalRating = template.rating.average * template.rating.count;
    template.rating.count += 1;
    template.rating.average = (totalRating + rating) / template.rating.count;

    await template.save();
    res.json({ template });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
