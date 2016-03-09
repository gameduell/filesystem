/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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

    public static var pathToTemporaryAssetArea(default, null): String;

	public static var foldersThatChanged: Array<String> = [];
	public static var fullRebuild: Bool = false;

	public static var hashList(default, null): Array<Int> = [];
	public static function registerProcessor(proc: Void->Void, prio: AssetProcessorPriority, currentHash: Int)
	{
		hashList.push(currentHash);
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
        for (proc in processorListHigh)
        {
            proc();
        }

        for (proc in processorListMedium)
        {
            proc();
        }

		for (proc in processorListLow)
		{
			proc();
		}
	}
}
