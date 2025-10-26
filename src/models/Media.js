const mongoose = require('mongoose');

const mediaSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
  },
  description: String,
  type: {
    type: String,
    enum: ['image', 'video', 'audio', 'document'],
    required: true,
  },
  fileUrl: {
    type: String,
    required: true,
  },
  fileSize: Number,
  mimeType: String,
  duration: Number, // for video/audio in seconds
  dimensions: {
    width: Number,
    height: Number,
  },
  thumbnail: String,
  owner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  projects: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Project',
  }],
  tags: [String],
  isPublic: {
    type: Boolean,
    default: false,
  },
  uploadedAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Media', mediaSchema);
