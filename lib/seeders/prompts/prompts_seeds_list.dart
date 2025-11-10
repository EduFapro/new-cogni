part of prompts_seeds;

final helloHowAreYouPrompt = TaskPromptEntity(
  promptID: helloHowAreYouTaskPromptID,
  taskID: helloHowAreYouTask.taskID!,
  filePath: AudioFilePaths.hello_how_are_you,
  transcription:
  "Olá, tudo bem! Agora vou fazer algumas perguntas para conhecer você melhor.",
);

final whatsYourNamePrompt = TaskPromptEntity(
  promptID: whatsYourNameTaskPromptID,
  taskID: whatsYourNameTask.taskID!,
  filePath: AudioFilePaths.whats_your_name,
  transcription: "Qual o seu nome?",
);

// ...continue the same pattern for ALL prompts 3–56...

final thankingForParticipationPrompt = TaskPromptEntity(
  promptID: thankingForParticipationTaskPromptID,
  taskID: thankingForParticipationTask.taskID!,
  filePath: AudioFilePaths.thanking_for_participation,
  transcription: "Obrigado pela sua participação.",
);

// Validation / test-only
final aPressaEhInimigaTaskPrompt = TaskPromptEntity(
  promptID: aPressaEhInimigaTaskPromptId,
  taskID: pressaInimigaTask.taskID!,
  filePath: AudioFilePaths.aPressaEhInimiga,
  transcription: "",
);

final conteAteh5TaskPrompt = TaskPromptEntity(
  promptID: conteAte5taskPromptID,
  taskID: conteAte5Task.taskID!,
  filePath: AudioFilePaths.conteAte5,
  transcription: "",
);

List<TaskPromptEntity> tasksPromptsList = [
  // main protocol (1–56) in exact ID order:
  helloHowAreYouPrompt,
  whatsYourNamePrompt,
  // ...
  thankingForParticipationPrompt,

  // test / validation prompts at the end:
  aPressaEhInimigaTaskPrompt,
  conteAteh5TaskPrompt,
];
