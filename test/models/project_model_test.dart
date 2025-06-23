import 'package:flutter_test/flutter_test.dart';
import 'package:project_tracker/models/project_model.dart';

void main() {
  group('Project Model Tests', () {
    test('Project creation with defaults', () {
      final project = Project(
        name: 'Test Project',
        description: 'A test project',
        status: ProjectStatus.building,
      );

      expect(project.name, 'Test Project');
      expect(project.description, 'A test project');
      expect(project.status, ProjectStatus.building);
      expect(project.notes, isEmpty);
      expect(project.statusHistory, isEmpty);
      expect(project.abandonReason, isNull);
      expect(project.id, isNotEmpty);
      expect(project.createdAt, isNotNull);
      expect(project.lastUpdated, isNotNull);
    });

    test('Days since last update calculation', () {
      final project = Project(
        name: 'Test Project',
        description: 'A test project',
        status: ProjectStatus.building,
        lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
      );

      expect(project.daysSinceLastUpdate, 5);
      expect(project.daysSinceLastUpdateText, 'Updated 5 days ago');
    });

    test('Status update functionality', () {
      final project = Project(
        name: 'Test Project',
        description: 'A test project',
        status: ProjectStatus.building,
      );

      project.updateStatus(ProjectStatus.shipped);

      expect(project.status, ProjectStatus.shipped);
      expect(project.statusHistory.length, 1);
      expect(project.statusHistory.first.from, ProjectStatus.building);
      expect(project.statusHistory.first.to, ProjectStatus.shipped);
    });

    test('Abandon project with reason', () {
      final project = Project(
        name: 'Test Project',
        description: 'A test project',
        status: ProjectStatus.building,
      );

      project.updateStatus(ProjectStatus.abandoned, reason: 'Lost interest');

      expect(project.status, ProjectStatus.abandoned);
      expect(project.abandonReason, 'Lost interest');
    });

    test('Add and parse notes', () {
      final project = Project(
        name: 'Test Project',
        description: 'A test project',
        status: ProjectStatus.building,
      );

      project.addNote('First note');
      project.addNote('Second note');

      expect(project.notes.length, 2);

      final parsedNotes = project.parsedNotes;
      expect(parsedNotes.length, 2);
      expect(parsedNotes[0]['note'], 'Second note'); // Most recent first
      expect(parsedNotes[1]['note'], 'First note');
    });
  });
}
