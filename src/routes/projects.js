const express = require('express');
const router = express.Router();
const projectController = require('../controllers/projectController');
const auth = require('../middleware/auth');

router.post('/', auth, projectController.createProject);
router.get('/', auth, projectController.getProjects);
router.get('/:id', auth, projectController.getProjectById);
router.put('/:id', auth, projectController.updateProject);
router.post('/:id/collaborators', auth, projectController.addCollaborator);
router.post('/:id/tasks', auth, projectController.addTask);
router.post('/:id/versions', auth, projectController.createVersion);

module.exports = router;
