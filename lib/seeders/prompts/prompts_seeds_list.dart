part of prompts_seeds;

final helloHowAreYouPrompt = TaskPromptEntity(
  promptID: helloHowAreYouTaskPromptID,
  taskID: helloHowAreYouTask.taskID!,
  filePath: AudioFilePaths.hello_how_are_you,
  transcription: "Olá, tudo bem! Agora vou fazer algumas perguntas para conhecer você melhor.",
);

final whatsYourNamePrompt = TaskPromptEntity(
  promptID: whatsYourNameTaskPromptID,
  taskID: whatsYourNameTask.taskID!,
  filePath: AudioFilePaths.whats_your_name,
  transcription: "Qual o seu nome?",
);

final whatsYourDOBPrompt = TaskPromptEntity(
  promptID: whatsYourDOBTaskPromptID,
  taskID: whatsYourDOBTask.taskID!,
  filePath: AudioFilePaths.whats_your_dob,
  transcription: "Qual a sua data de nascimento?",
);

final whatsYourEducationLevelPrompt = TaskPromptEntity(
  promptID: whatsYourEducationLevelTaskPromptID,
  taskID: whatsYourEducationLevelTask.taskID!,
  filePath: AudioFilePaths.whats_your_education_level,
  transcription: "Qual a sua escolaridade? Me diga até quando você estudou:",
);

final whatWasYourProfessionPrompt = TaskPromptEntity(
  promptID: whatWasYourProfessionTaskPromptID,
  taskID: whatWasYourProfessionTask.taskID!,
  filePath: AudioFilePaths.what_was_your_profession,
  transcription: "Qual era a sua profissão?",
);

final whoDoYouLiveWithPrompt = TaskPromptEntity(
  promptID: whoDoYouLiveWithTaskPromptID,
  taskID: whoDoYouLiveWithTask.taskID!,
  filePath: AudioFilePaths.who_do_you_live_with,
  transcription: "Com quem você mora atualmente?",
);

final doYouExerciseFrequentlyPrompt = TaskPromptEntity(
  promptID: doYouExerciseFrequentlyTaskPromptID,
  taskID: doYouExerciseFrequentlyTask.taskID!,
  filePath: AudioFilePaths.do_you_exercise_frequently,
  transcription: "Você faz alguma atividade física com frequência?",
);

final doYouReadFrequentlyPrompt = TaskPromptEntity(
  promptID: doYouReadFrequentlyTaskPromptID,
  taskID: doYouReadFrequentlyTask.taskID!,
  filePath: AudioFilePaths.do_you_read_frequently,
  transcription: "Você costuma ler com frequência?",
);

final doYouPlayPuzzlesOrVideoGamesFrequentlyPrompt = TaskPromptEntity(
  promptID: doYouPlayPuzzlesOrVideoGamesFrequentlyTaskPromptID,
  taskID: doYouPlayPuzzlesOrVideoGamesFrequentlyTask.taskID!,
  filePath: AudioFilePaths.do_you_play_puzzles_or_video_games_frequently,
  transcription:
  "Você costuma jogar palavras-cruzadas, caça-palavras ou jogos eletrônicos com frequência?",
);

final doYouHaveAnyDiseasesPrompt = TaskPromptEntity(
  promptID: doYouHaveAnyDiseaseTaskPromptID,
  taskID: doYouHaveAnyDiseasesTask.taskID!,
  filePath: AudioFilePaths.do_you_have_any_diseases,
  transcription: "Algum médico já disse que você tem alguma doença? Me diga quais são essas doenças:",
);

final aPressaEhInimigaTaskPrompt = TaskPromptEntity(
  promptID: aPressaEhInimigaTaskPromptId,
  taskID: pressaInimigaTask.taskID!,
  filePath: AudioFilePaths.aPressaEhInimiga,
);

final conteAteh5TaskPrompt = TaskPromptEntity(
  promptID: conteAte5taskPromptID,
  taskID: conteAte5Task.taskID!,
  filePath: AudioFilePaths.conteAte5,
);

List<TaskPromptEntity> tasksPromptsList = [
  helloHowAreYouPrompt,
  whatsYourNamePrompt,
  whatsYourDOBPrompt,
  whatsYourEducationLevelPrompt,
  whatWasYourProfessionPrompt,
  whoDoYouLiveWithPrompt,
  doYouExerciseFrequentlyPrompt,
  doYouReadFrequentlyPrompt,
  doYouPlayPuzzlesOrVideoGamesFrequentlyPrompt,
  doYouHaveAnyDiseasesPrompt,
  aPressaEhInimigaTaskPrompt,
  conteAteh5TaskPrompt,
];
