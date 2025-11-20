enum ParticipantStatusFilter {
  all('Todos'),
  completed('Concluídos'),
  pending('Pendentes'),
  inProgress('Em andamento'),
  notStarted('Não iniciados');

  final String label;
  const ParticipantStatusFilter(this.label);
}
