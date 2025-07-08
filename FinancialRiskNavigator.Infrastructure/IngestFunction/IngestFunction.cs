public class IngestFunction
{
	private readonly ServiceBusClient _sbClient;
	private readonly ILogger _logger;
	private readonly string _queueName;

	public IngestFunction(ServiceBusClient serviceBusClient, ILoggerFactory loggerFactory)
	{
		_sbClient = serviceBusClient;
		_logger = loggerFactory.CreateLogger<RiskIngestor>();
		_queueName = Environment.GetEnvironmentVariable("ServiceBusQueue");
	}

	[Function("IngestFunction")]
	public async Task Run(
			[EventHubTrigger("risk-events", Connection = "EventHubConnection")] string[] events)
	{
		var sender = _sbClient.CreateSender(_queueName);

		foreach (var message in events)
		{
			_logger.LogInformation("Received event: {0}", message);
			await sender.SendMessageAsync(new ServiceBusMessage(message));
		}

		await sender.DisposeAsync();
	}
}
