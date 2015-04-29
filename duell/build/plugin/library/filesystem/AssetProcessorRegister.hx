package duell.build.plugin.library.filesystem;

enum AssetProcessorPriority
{
	AssetProcessorPriorityHigh; /// going first
	AssetProcessorPriorityMedium; /// going to the middle
	AssetProcessorPriorityLow; /// going last
}

class AssetProcessorRegister
{
	private static var processorListMedium: Array<Void->Void> = [];
	private static var processorListLow: Array<Void->Void> = [];
	private static var processorListHigh: Array<Void->Void> = [];
	public static function registerProcessor(proc: Void->Void, prio: AssetProcessorPriority)
	{
		switch(prio)
		{
			case(AssetProcessorPriorityHigh):
				processorListHigh.push(proc);

			case(AssetProcessorPriorityMedium):
				processorListMedium.push(proc);

			case(AssetProcessorPriorityLow):
				processorListLow.push(proc);
		}
	}

	public static function process()
	{
		for (proc in processorListLow)
		{
			proc();
		}

		for (proc in processorListMedium)
		{
			proc();
		}

		for (proc in processorListHigh)
		{
			proc();
		}
	}
}
