part of task_seeds;

// Helper: default transcript = '' unless specified.

/// --- Sociodemographic Info ---

final helloHowAreYouTask = TaskEntity(
  taskID: helloHowAreYouTaskID,
  moduleID: sociodemographicInfoId,
  title: helloHowAreYouTaskTitle,
  transcript:
      'Olá, tudo bem! Agora vou fazer algumas perguntas para conhecer você melhor.',
  videoAssetPath: VideoFilePaths.hello_how_are_you,
  taskMode: TaskMode.play,
  position: 1,
);

final whatsYourNameTask = TaskEntity(
  taskID: whatsYourNameTaskID,
  moduleID: sociodemographicInfoId,
  title: whatsYourNameTaskTitle,
  videoAssetPath: VideoFilePaths.whats_your_name,
  taskMode: TaskMode.record,
  position: 2,
);

final whatsYourDOBTask = TaskEntity(
  taskID: whatsYourDOBTaskID,
  moduleID: sociodemographicInfoId,
  title: whatsYourDOBTaskTitle,
  videoAssetPath: VideoFilePaths.whats_your_dob,
  taskMode: TaskMode.record,
  position: 3,
);

final whatsYourEducationLevelTask = TaskEntity(
  taskID: whatsYourEducationLevelTaskID,
  moduleID: sociodemographicInfoId,
  title: whatsYourEducationLevelTaskTitle,
  videoAssetPath: VideoFilePaths.whats_your_education_level,
  taskMode: TaskMode.record,
  position: 4,
);

final whatWasYourProfessionTask = TaskEntity(
  taskID: whatWasYourProfessionTaskID,
  moduleID: sociodemographicInfoId,
  title: whatWasYourProfessionTaskTitle,
  videoAssetPath: VideoFilePaths.what_was_your_profession,
  taskMode: TaskMode.record,
  position: 5,
);

final whoDoYouLiveWithTask = TaskEntity(
  taskID: whoDoYouLiveWithTaskID,
  moduleID: sociodemographicInfoId,
  title: whoDoYouLiveWithTaskTitle,
  videoAssetPath: VideoFilePaths.who_do_you_live_with,
  taskMode: TaskMode.record,
  position: 6,
);

final doYouExerciseFrequentlyTask = TaskEntity(
  taskID: doYouExerciseFrequentlyTaskID,
  moduleID: sociodemographicInfoId,
  title: doYouExerciseFrequentlyTaskTitle,
  videoAssetPath: VideoFilePaths.do_you_exercise_frequently,
  taskMode: TaskMode.record,
  position: 7,
);

final doYouReadFrequentlyTask = TaskEntity(
  taskID: doYouReadFrequentlyTaskID,
  moduleID: sociodemographicInfoId,
  title: doYouReadFrequentlyTaskTitle,
  videoAssetPath: VideoFilePaths.do_you_read_frequently,
  taskMode: TaskMode.record,
  position: 8,
);

final doYouPlayPuzzlesOrVideoGamesFrequentlyTask = TaskEntity(
  taskID: doYouPlayPuzzlesOrVideoGamesFrequentlyTaskID,
  moduleID: sociodemographicInfoId,
  title: doYouPlayPuzzlesOrVideoGamesFrequentlyTaskTitle,
  videoAssetPath: VideoFilePaths.do_you_play_puzzles_or_video_games_frequently,
  taskMode: TaskMode.record,
  position: 9,
);

final doYouHaveAnyDiseasesTask = TaskEntity(
  taskID: doYouHaveAnyDiseasesTaskID,
  moduleID: sociodemographicInfoId,
  title: doYouHaveAnyDiseasesTaskTitle,
  videoAssetPath: VideoFilePaths.do_you_have_any_diseases,
  taskMode: TaskMode.record,
  position: 10,
);

/// --- Cognitive Functions ---

final payCloseAttentionTask = TaskEntity(
  taskID: payCloseAttentionTaskID,
  moduleID: cognitiveFunctionsId,
  title: payCloseAttentionTaskTitle,
  taskMode: TaskMode.play,
  mayRepeatPrompt: true,
  position: 1,
);

final subtracting3AndAgainTask = TaskEntity(
  taskID: subtracting3AndAgainTaskID,
  moduleID: cognitiveFunctionsId,
  title: subtracting3AndAgainTaskTitle,
  taskMode: TaskMode.record,
  position: 2,
);

final whatYearAreWeInTask = TaskEntity(
  taskID: whatYearAreWeInTaskID,
  moduleID: cognitiveFunctionsId,
  title: whatYearAreWeInTaskTitle,
  taskMode: TaskMode.record,
  position: 3,
);

final whatMonthAreWeInTask = TaskEntity(
  taskID: whatMonthAreWeInTaskID,
  moduleID: cognitiveFunctionsId,
  title: whatMonthAreWeInTaskTitle,
  taskMode: TaskMode.record,
  position: 4,
);

final whatDayOfTheMonthIsItTask = TaskEntity(
  taskID: whatDayOfTheMonthIsItTaskID,
  moduleID: cognitiveFunctionsId,
  title: whatDayOfTheMonthIsItTaskTitle,
  taskMode: TaskMode.record,
  position: 5,
);

final whatDayOfTheWeekIsItTask = TaskEntity(
  taskID: whatDayOfTheWeekIsItTaskID,
  moduleID: cognitiveFunctionsId,
  title: whatDayOfTheWeekIsItTaskTitle,
  taskMode: TaskMode.record,
  position: 6,
);

final howOldAreYouTask = TaskEntity(
  taskID: howOldAreYouTaskID,
  moduleID: cognitiveFunctionsId,
  title: howOldAreYouTaskTitle,
  taskMode: TaskMode.record,
  position: 7,
);

final whereAreWeNowTask = TaskEntity(
  taskID: whereAreWeNowTaskID,
  moduleID: cognitiveFunctionsId,
  title: whereAreWeNowTaskTitle,
  taskMode: TaskMode.record,
  position: 8,
);

final currentPresidentOfBrazilTask = TaskEntity(
  taskID: currentPresidentOfBrazilTaskID,
  moduleID: cognitiveFunctionsId,
  title: currentPresidentOfBrazilTaskTitle,
  taskMode: TaskMode.record,
  position: 9,
);

final formerPresidentOfBrazilTask = TaskEntity(
  taskID: formerPresidentOfBrazilTaskID,
  moduleID: cognitiveFunctionsId,
  title: formerPresidentOfBrazilTaskTitle,
  taskMode: TaskMode.record,
  position: 10,
);

final repeatWordsAfterListeningFirstTimeTask = TaskEntity(
  taskID: repeatWordsAfterListeningFirstTimeTaskID,
  moduleID: cognitiveFunctionsId,
  title: repeatWordsAfterListeningFirstTimeTaskTitle,
  taskMode: TaskMode.play,
  mayRepeatPrompt: true,
  position: 11,
);

final recallWordsFromListFirstTimeTask = TaskEntity(
  taskID: recallWordsFromListFirstTimeTaskID,
  moduleID: cognitiveFunctionsId,
  title: recallWordsFromListFirstTimeTaskTitle,
  taskMode: TaskMode.record,
  mayRepeatPrompt: false,
  position: 12,
);

final repeatWordsAfterListeningSecondTimeTask = TaskEntity(
  taskID: repeatWordsAfterListeningSecondTimeTaskID,
  moduleID: cognitiveFunctionsId,
  title: repeatWordsAfterListeningSecondTimeTaskTitle,
  taskMode: TaskMode.play,
  mayRepeatPrompt: true,
  position: 13,
);

final recallWordsFromListSecondTimeTask = TaskEntity(
  taskID: recallWordsFromListSecondTimeTaskID,
  moduleID: cognitiveFunctionsId,
  title: recallWordsFromListSecondTimeTaskTitle,
  taskMode: TaskMode.record,
  mayRepeatPrompt: false,
  position: 14,
);

final repeatWordsAfterListeningThirdTimeTask = TaskEntity(
  taskID: repeatWordsAfterListeningThirdTimeTaskID,
  moduleID: cognitiveFunctionsId,
  title: repeatWordsAfterListeningThirdTimeTaskTitle,
  taskMode: TaskMode.play,
  mayRepeatPrompt: true,
  position: 15,
);

final recallWordsFromListThirdTimeTask = TaskEntity(
  taskID: recallWordsFromListThirdTimeTaskID,
  moduleID: cognitiveFunctionsId,
  title: recallWordsFromListThirdTimeTaskTitle,
  taskMode: TaskMode.record,
  mayRepeatPrompt: false,
  position: 16,
);

final whatDidYouDoYesterdayTask = TaskEntity(
  taskID: whatDidYouDoYesterdayTaskID,
  moduleID: cognitiveFunctionsId,
  title: whatDidYouDoYesterdayTaskTitle,
  taskMode: TaskMode.record,
  position: 17,
);

final favoriteChildhoodGameTask = TaskEntity(
  taskID: favoriteChildhoodGameTaskID,
  moduleID: cognitiveFunctionsId,
  title: favoriteChildhoodGameTaskTitle,
  taskMode: TaskMode.record,
  position: 18,
);

final retellWordsHeardBeforeTask = TaskEntity(
  taskID: retellWordsHeardBeforeTaskID,
  moduleID: cognitiveFunctionsId,
  title: retellWordsHeardBeforeTaskTitle,
  taskMode: TaskMode.record,
  position: 19,
);

final payCloseAttentionToTheStoryTask = TaskEntity(
  taskID: payCloseAttentionToTheStoryTaskID,
  moduleID: cognitiveFunctionsId,
  title: payCloseAttentionToTheStoryTaskTitle,
  taskMode: TaskMode.play,
  mayRepeatPrompt: true,
  position: 20,
);

final anasCatStoryTask = TaskEntity(
  taskID: anasCatStoryTaskID,
  moduleID: cognitiveFunctionsId,
  title: anasCatStoryTaskTitle,
  taskMode: TaskMode.record,
  mayRepeatPrompt: false,
  position: 21,
);

final howManyAnimalsCanYouThinkOfTask = TaskEntity(
  taskID: howManyAnimalsCanYouThinkOfTaskID,
  moduleID: cognitiveFunctionsId,
  title: howManyAnimalsCanYouThinkOfTaskTitle,
  taskMode: TaskMode.record,
  position: 22,
);

final wordsStartingWithFTask = TaskEntity(
  taskID: wordsStartingWithFTaskID,
  moduleID: cognitiveFunctionsId,
  title: wordsStartingWithFTaskTitle,
  taskMode: TaskMode.record,
  position: 23,
);

final wordsStartingWithATask = TaskEntity(
  taskID: wordsStartingWithATaskID,
  moduleID: cognitiveFunctionsId,
  title: wordsStartingWithATaskTitle,
  taskMode: TaskMode.record,
  position: 24,
);

final wordsStartingWithSTask = TaskEntity(
  taskID: wordsStartingWithSTaskID,
  moduleID: cognitiveFunctionsId,
  title: wordsStartingWithSTaskTitle,
  taskMode: TaskMode.record,
  position: 25,
);

final describeWhatYouSeeTask = TaskEntity(
  taskID: describeWhatYouSeeTaskID,
  moduleID: cognitiveFunctionsId,
  title: describeWhatYouSeeTaskTitle,
  taskMode: TaskMode.record,
  imageAssetPath: 'assets/images/imagem_sala.png',
  // Requires video to play first
  videoAssetPath:
      'assets/video/task_prompts/Joana/02-Funcoes_Cognitivas/08_JOANA_FUNCOES_COGNITIVAS_nomeacao.mp4', // Example, check actual path
  position: 26,
);

final retellStoryTask = TaskEntity(
  taskID: retellStoryTaskID,
  moduleID: cognitiveFunctionsId,
  title: retellStoryTaskTitle,
  taskMode: TaskMode.record,
  position: 27,
);

/// --- Functionality ---

final yesOrNoQuestionsTask = TaskEntity(
  taskID: yesOrNoQuestionsTaskID,
  moduleID: functionalityId,
  title: yesOrNoQuestionsTaskTitle,
  taskMode: TaskMode.play,
  position: 1,
);

final canYouBatheAloneTask = TaskEntity(
  taskID: canYouBatheAloneTaskID,
  moduleID: functionalityId,
  title: canYouBatheAloneTaskTitle,
  taskMode: TaskMode.record,
  position: 2,
);

final canYouDressAloneTask = TaskEntity(
  taskID: canYouDressAloneTaskID,
  moduleID: functionalityId,
  title: canYouDressAloneTaskTitle,
  taskMode: TaskMode.record,
  position: 3,
);

final canYouUseToiletAloneTask = TaskEntity(
  taskID: canYouUseToiletAloneTaskID,
  moduleID: functionalityId,
  title: canYouUseToiletAloneTaskTitle,
  taskMode: TaskMode.record,
  position: 4,
);

final canYouUsePhoneAloneTask = TaskEntity(
  taskID: canYouUsePhoneAloneTaskID,
  moduleID: functionalityId,
  title: canYouUsePhoneAloneTaskTitle,
  taskMode: TaskMode.record,
  position: 5,
);

final canYouShopAloneTask = TaskEntity(
  taskID: canYouShopAloneTaskID,
  moduleID: functionalityId,
  title: canYouShopAloneTaskTitle,
  taskMode: TaskMode.record,
  position: 6,
);

final canYouHandleMoneyAloneTask = TaskEntity(
  taskID: canYouHandleMoneyAloneTaskID,
  moduleID: functionalityId,
  title: canYouHandleMoneyAloneTaskTitle,
  taskMode: TaskMode.record,
  position: 7,
);

final canYouManageMedicationAloneTask = TaskEntity(
  taskID: canYouManageMedicationAloneTaskID,
  moduleID: functionalityId,
  title: canYouManageMedicationAloneTaskTitle,
  taskMode: TaskMode.record,
  position: 8,
);

final canYouUseTransportAloneTask = TaskEntity(
  taskID: canYouUseTransportAloneTaskID,
  moduleID: functionalityId,
  title: canYouUseTransportAloneTaskTitle,
  taskMode: TaskMode.record,
  position: 9,
);

/// --- Depression Symptoms ---

final feelingsInPastTwoWeeksTask = TaskEntity(
  taskID: feelingsInPastTwoWeeksTaskID,
  moduleID: depressionSymptomsId,
  title: feelingsInPastTwoWeeksTaskTitle,
  taskMode: TaskMode.play,
  position: 1,
);

final feelingSadFrequentlyTask = TaskEntity(
  taskID: feelingSadFrequentlyTaskID,
  moduleID: depressionSymptomsId,
  title: feelingSadFrequentlyTaskTitle,
  taskMode: TaskMode.record,
  position: 2,
);

final feelingTiredOrLackingEnergyTask = TaskEntity(
  taskID: feelingTiredOrLackingEnergyTaskID,
  moduleID: depressionSymptomsId,
  title: feelingTiredOrLackingEnergyTaskTitle,
  taskMode: TaskMode.record,
  position: 3,
);

final troubleSleepingTask = TaskEntity(
  taskID: troubleSleepingTaskID,
  moduleID: depressionSymptomsId,
  title: troubleSleepingTaskTitle,
  taskMode: TaskMode.record,
  position: 4,
);

final preferringToStayHomeTask = TaskEntity(
  taskID: preferringToStayHomeTaskID,
  moduleID: depressionSymptomsId,
  title: preferringToStayHomeTaskTitle,
  taskMode: TaskMode.record,
  position: 5,
);

final feelingUselessOrGuiltyTask = TaskEntity(
  taskID: feelingUselessOrGuiltyTaskID,
  moduleID: depressionSymptomsId,
  title: feelingUselessOrGuiltyTaskTitle,
  taskMode: TaskMode.record,
  position: 6,
);

final lostInterestInActivitiesTask = TaskEntity(
  taskID: lostInterestInActivitiesTaskID,
  moduleID: depressionSymptomsId,
  title: lostInterestInActivitiesTaskTitle,
  taskMode: TaskMode.record,
  position: 7,
);

final hopefulAboutFutureTask = TaskEntity(
  taskID: hopefulAboutFutureTaskID,
  moduleID: depressionSymptomsId,
  title: hopefulAboutFutureTaskTitle,
  taskMode: TaskMode.record,
  position: 8,
);

final feelingLifeIsWorthLivingTask = TaskEntity(
  taskID: feelingLifeIsWorthLivingTaskID,
  moduleID: depressionSymptomsId,
  title: feelingLifeIsWorthLivingTaskTitle,
  taskMode: TaskMode.record,
  position: 9,
);

final thankingForParticipationTask = TaskEntity(
  taskID: thankingForParticipationTaskID,
  moduleID: depressionSymptomsId,
  title: thankingForParticipationTaskTitle,
  taskMode: TaskMode.play,
  position: 10,
);

/// --- Test / Verification ---

final pressaInimigaTask = TaskEntity(
  taskID: pressaInimigaTaskID,
  moduleID: testsModuleId,
  title: pressaInimigaTaskTitle,
  taskMode: TaskMode.play,
  testOnly: true,
  position: 1,
);

final conteAte5Task = TaskEntity(
  taskID: conteAte5TaskID,
  moduleID: testsModuleId,
  title: conteAte5TaskTitle,
  taskMode: TaskMode.record,
  testOnly: true,
  position: 2,
);

/// Master list used by the seeder.

final List<TaskEntity> tasksList = [
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
  payCloseAttentionTask,
  subtracting3AndAgainTask,
  whatYearAreWeInTask,
  whatMonthAreWeInTask,
  whatDayOfTheMonthIsItTask,
  whatDayOfTheWeekIsItTask,
  howOldAreYouTask,
  whereAreWeNowTask,
  currentPresidentOfBrazilTask,
  formerPresidentOfBrazilTask,
  repeatWordsAfterListeningFirstTimeTask,
  recallWordsFromListFirstTimeTask,
  repeatWordsAfterListeningSecondTimeTask,
  recallWordsFromListSecondTimeTask,
  repeatWordsAfterListeningThirdTimeTask,
  recallWordsFromListThirdTimeTask,
  whatDidYouDoYesterdayTask,
  favoriteChildhoodGameTask,
  retellWordsHeardBeforeTask,
  payCloseAttentionToTheStoryTask,
  anasCatStoryTask,
  howManyAnimalsCanYouThinkOfTask,
  wordsStartingWithFTask,
  wordsStartingWithATask,
  wordsStartingWithSTask,
  describeWhatYouSeeTask,
  retellStoryTask,
  yesOrNoQuestionsTask,
  canYouBatheAloneTask,
  canYouDressAloneTask,
  canYouUseToiletAloneTask,
  canYouUsePhoneAloneTask,
  canYouShopAloneTask,
  canYouHandleMoneyAloneTask,
  canYouManageMedicationAloneTask,
  canYouUseTransportAloneTask,
  feelingsInPastTwoWeeksTask,
  feelingSadFrequentlyTask,
  feelingTiredOrLackingEnergyTask,
  troubleSleepingTask,
  preferringToStayHomeTask,
  feelingUselessOrGuiltyTask,
  lostInterestInActivitiesTask,
  hopefulAboutFutureTask,
  feelingLifeIsWorthLivingTask,
  thankingForParticipationTask,
  pressaInimigaTask,
  conteAte5Task,
];
