part of task_seeds;

// === Sociodemographic Module Tasks ===


TaskEntity helloHowAreYouTask = TaskEntity(
  taskID: helloHowAreYouTaskId,
  title: helloHowAreYouTaskTitle,
  transcript: helloHowAreYouTaskSnakeCaseTranscript,
  moduleID: sociodemographicInfoId,
  taskMode: TaskMode.play,
  timeForCompletion: 60,
  mayRepeatPrompt: true,
  position: 1,
);

TaskEntity whatsYourNameTask = TaskEntity(
  taskID: whatsYourNameTaskId,
  title: whatsYourNameTaskTitle,
  transcript: whatsYourNameTaskSnakeCaseTranscript,
  moduleID: sociodemographicInfoId,
  taskMode: TaskMode.record,
  timeForCompletion: 60,
  mayRepeatPrompt: true,
  position: 2,
);

TaskEntity whatsYourDOBTask = TaskEntity(
  taskID: whatsYourDOBTaskId,
  title: whatsYourDOBTaskTitle,
  transcript: whatsYourDOBTaskSnakeCaseTranscript,
  moduleID: sociodemographicInfoId,
  taskMode: TaskMode.record,
  timeForCompletion: 60,
  mayRepeatPrompt: true,
  position: 3,
);

TaskEntity whatsYourEducationLevelTask = TaskEntity(
  taskID: whatsYourEducationLevelTaskId,
  title: whatsYourEducationLevelTaskTitle,
  transcript: whatsYourEducationLevelTaskSnakeCaseTranscript,
  moduleID: sociodemographicInfoId,
  taskMode: TaskMode.record,
  timeForCompletion: 60,
  mayRepeatPrompt: true,
  position: 4,
);

TaskEntity whatWasYourProfessionTask = TaskEntity(
  taskID: whatWasYourProfessionTaskId,
  title: whatWasYourProfessionTaskTitle,
  transcript: whatWasYourProfessionTaskSnakeCaseTranscript,
  moduleID: sociodemographicInfoId,
  taskMode: TaskMode.record,
  timeForCompletion: 60,
  mayRepeatPrompt: true,
  position: 5,
);

TaskEntity whoDoYouLiveWithTask = TaskEntity(
  taskID: whoDoYouLiveWithTaskId,
  title: whoDoYouLiveWithTaskTitle,
  transcript: whoDoYouLiveWithTaskSnakeCaseTranscript,
  moduleID: sociodemographicInfoId,
  taskMode: TaskMode.record,
  timeForCompletion: 60,
  mayRepeatPrompt: true,
  position: 6,
);

TaskEntity doYouExerciseFrequentlyTask = TaskEntity(
  taskID: doYouExerciseFrequentlyTaskId,
  title: doYouExerciseFrequentlyTaskTitle,
  transcript: doYouExerciseFrequentlyTaskSnakeCaseTranscript,
  moduleID: sociodemographicInfoId,
  taskMode: TaskMode.record,
  timeForCompletion: 60,
  mayRepeatPrompt: true,
  position: 7,
);

TaskEntity doYouReadFrequentlyTask = TaskEntity(
  taskID: doYouReadFrequentlyTaskId,
  title: doYouReadFrequentlyTaskTitle,
  transcript: doYouReadFrequentlyTaskSnakeCaseTranscript,
  moduleID: sociodemographicInfoId,
  taskMode: TaskMode.record,
  timeForCompletion: 60,
  mayRepeatPrompt: true,
  position: 8,
);

TaskEntity doYouPlayPuzzlesOrVideoGamesFrequentlyTask = TaskEntity(
  taskID: doYouPlayPuzzlesOrVideoGamesFrequentlyTaskId,
  title: doYouPlayPuzzlesOrVideoGamesFrequentlyTaskTitle,
  transcript: doYouPlayPuzzlesOrVideoGamesFrequentlyTaskSnakeCaseTranscript,
  moduleID: sociodemographicInfoId,
  taskMode: TaskMode.record,
  timeForCompletion: 60,
  mayRepeatPrompt: true,
  position: 9,
);

TaskEntity doYouHaveAnyDiseasesTask = TaskEntity(
  taskID: doYouHaveAnyDiseasesTaskId,
  title: doYouHaveAnyDiseasesTaskTitle,
  transcript: doYouHaveAnyDiseasesTaskSnakeCaseTranscript,
  moduleID: sociodemographicInfoId,
  taskMode: TaskMode.record,
  timeForCompletion: 60,
  mayRepeatPrompt: true,
  position: 10,
);

// === Validation Tasks ===

TaskEntity pressaInimigaTask = TaskEntity(
  taskID: pressaInimigaTaskId,
  title: pressaInimigaTaskTitle,
  transcript: pressaInimigaTaskSnakeCaseTranscript,
  moduleID: testsModuleId,
  taskMode: TaskMode.play,
  timeForCompletion: 60,
  mayRepeatPrompt: true,
  position: 1,
);

TaskEntity conteAte5Task = TaskEntity(
  taskID: conteAte5TaskId,
  title: conteAte5TaskTitle,
  transcript: conteAte5TaskSnakeCaseTranscript,
  moduleID: testsModuleId,
  taskMode: TaskMode.record,
  timeForCompletion: 60,
  mayRepeatPrompt: true,
  position: 2,
);

List<TaskEntity> tasksList = [
  helloHowAreYouTask,
  whatsYourNameTask,
  whatsYourDOBTask,
  whatsYourEducationLevelTask,
  whatWasYourProfessionTask,
  whoDoYouLiveWithTask,
  doYouExerciseFrequentlyTask,
  doYouReadFrequentlyTask,
  doYouPlayPuzzlesOrVideoGamesFrequentlyTask,
  doYouHaveAnyDiseasesTask,
  pressaInimigaTask,
  conteAte5Task,
];
