const express = require('express');
const router = express.Router();
const mediaController = require('../controllers/mediaController');
const auth = require('../middleware/auth');

router.post('/', auth, mediaController.createMedia);
router.get('/', auth, mediaController.getMedia);
router.get('/:id', auth, mediaController.getMediaById);
router.put('/:id', auth, mediaController.updateMedia);
router.delete('/:id', auth, mediaController.deleteMedia);

module.exports = router;
