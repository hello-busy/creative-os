const Notification = require('../models/Notification');

// Get user's notifications
exports.getNotifications = async (req, res) => {
  try {
    const { type, unreadOnly } = req.query;
    const query = { recipient: req.user._id };

    if (type) query.type = type;
    if (unreadOnly === 'true') query.isRead = false;

    // Don't show snoozed notifications until snooze time has passed
    query.$or = [
      { isSnoozed: false },
      { snoozedUntil: { $lt: new Date() } },
    ];

    const notifications = await Notification.find(query)
      .populate('sender', 'username email')
      .sort({ createdAt: -1 })
      .limit(50);

    res.json({ notifications });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Mark notification as read
exports.markAsRead = async (req, res) => {
  try {
    const notification = await Notification.findById(req.params.id);

    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    if (!notification.recipient.equals(req.user._id)) {
      return res.status(403).json({ message: 'Access denied' });
    }

    notification.isRead = true;
    await notification.save();

    res.json({ notification });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Mark all as read
exports.markAllAsRead = async (req, res) => {
  try {
    await Notification.updateMany(
      { recipient: req.user._id, isRead: false },
      { isRead: true }
    );

    res.json({ message: 'All notifications marked as read' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Snooze notification
exports.snoozeNotification = async (req, res) => {
  try {
    const { minutes } = req.body;
    const notification = await Notification.findById(req.params.id);

    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    if (!notification.recipient.equals(req.user._id)) {
      return res.status(403).json({ message: 'Access denied' });
    }

    notification.isSnoozed = true;
    notification.snoozedUntil = new Date(Date.now() + minutes * 60000);
    await notification.save();

    res.json({ notification });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

// Create notification (internal use)
exports.createNotification = async (recipientId, type, title, message, options = {}) => {
  try {
    const notification = new Notification({
      recipient: recipientId,
      sender: options.senderId,
      type,
      title,
      message,
      link: options.link,
      relatedModel: options.relatedModel,
      relatedId: options.relatedId,
    });

    await notification.save();
    return notification;
  } catch (error) {
    console.error('Error creating notification:', error);
    return null;
  }
};
