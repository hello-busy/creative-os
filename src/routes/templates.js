const express = require('express');
const router = express.Router();
const templateController = require('../controllers/templateController');
const auth = require('../middleware/auth');

router.post('/', auth, templateController.createTemplate);
router.get('/', auth, templateController.getTemplates);
router.get('/:id', auth, templateController.getTemplateById);
router.post('/:id/use', auth, templateController.useTemplate);
router.post('/:id/rate', auth, templateController.rateTemplate);

module.exports = router;
