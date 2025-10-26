const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  recipient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  sender: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  type: {
    type: String,
    enum: ['mention', 'comment', 'like', 'deadline', 'invite', 'system'],
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  message: String,
  link: String,
  relatedModel: String,
  relatedId: mongoose.Schema.Types.ObjectId,
  isRead: {
    type: Boolean,
    default: false,
  },
  isSnoozed: {
    type: Boolean,
    default: false,
  },
  snoozedUntil: Date,
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Notification', notificationSchema);
