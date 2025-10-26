const Project = require('../models/Project');
const User = require('../models/User');

// Create a new project
exports.createProject = async (req, res) => {
  try {
    const { title, description, type, dueDate, tags } = req.body;
    
    const project = new Project({
      title,
      description,
      type,
      owner: req.user._id,
      dueDate,
      tags: tags || [],
    });

    await project.save();
    await project.populate('owner', 'username email');

    res.status(201).json({ project });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Get user's projects
exports.getProjects = async (req, res) => {
  try {
    const { status, type } = req.query;
    const query = {
      $or: [
        { owner: req.user._id },
        { 'collaborators.user': req.user._id },
      ],
    };

    if (status) query.status = status;
    if (type) query.type = type;

    const projects = await Project.find(query)
      .populate('owner', 'username email')
      .populate('collaborators.user', 'username email')
      .sort({ updatedAt: -1 });

    res.json({ projects });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Get project details
exports.getProjectById = async (req, res) => {
  try {
    const project = await Project.findById(req.params.id)
      .populate('owner', 'username email')
      .populate('collaborators.user', 'username email')
      .populate('tasks.assignedTo', 'username email')
      .populate('media');

    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    // Check if user has access
    const hasAccess = project.owner.equals(req.user._id) ||
      project.collaborators.some(c => c.user.equals(req.user._id));

    if (!hasAccess) {
      return res.status(403).json({ message: 'Access denied' });
    }

    res.json({ project });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Update project
exports.updateProject = async (req, res) => {
  try {
    const project = await Project.findById(req.params.id);

    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    if (!project.owner.equals(req.user._id)) {
      return res.status(403).json({ message: 'Only owner can update project' });
    }

    const updates = ['title', 'description', 'status', 'dueDate', 'publishDate', 'tags'];
    updates.forEach(field => {
      if (req.body[field] !== undefined) {
        project[field] = req.body[field];
      }
    });

    await project.save();
    await project.populate('owner', 'username email');

    res.json({ project });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Add collaborator
exports.addCollaborator = async (req, res) => {
  try {
    const { userId, role } = req.body;
    const project = await Project.findById(req.params.id);

    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    if (!project.owner.equals(req.user._id)) {
      return res.status(403).json({ message: 'Only owner can add collaborators' });
    }

    // Check if user exists
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Check if already a collaborator
    if (project.collaborators.some(c => c.user.equals(userId))) {
      return res.status(400).json({ message: 'User is already a collaborator' });
    }

    project.collaborators.push({ user: userId, role: role || 'viewer' });
    await project.save();
    await project.populate('collaborators.user', 'username email');

    res.json({ project });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Add task
exports.addTask = async (req, res) => {
  try {
    const { title, description, assignedTo, dueDate } = req.body;
    const project = await Project.findById(req.params.id);

    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    const hasAccess = project.owner.equals(req.user._id) ||
      project.collaborators.some(c => c.user.equals(req.user._id) && ['admin', 'editor'].includes(c.role));

    if (!hasAccess) {
      return res.status(403).json({ message: 'Access denied' });
    }

    project.tasks.push({ title, description, assignedTo, dueDate });
    await project.save();

    res.json({ project });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Create version
exports.createVersion = async (req, res) => {
  try {
    const { name, description } = req.body;
    const project = await Project.findById(req.params.id);

    if (!project) {
      return res.status(404).json({ message: 'Project not found' });
    }

    const hasAccess = project.owner.equals(req.user._id) ||
      project.collaborators.some(c => c.user.equals(req.user._id) && ['admin', 'editor'].includes(c.role));

    if (!hasAccess) {
      return res.status(403).json({ message: 'Access denied' });
    }

    const versionNumber = project.versions.length + 1;
    project.versions.push({
      versionNumber,
      name,
      description,
      createdBy: req.user._id,
    });

    await project.save();
    res.json({ project });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
