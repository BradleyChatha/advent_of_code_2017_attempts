import std.stdio;
import std.typecons;

alias DoPartTwo = Flag!"partTwo";

const INPUT = "14	0	15	12	11	11	3	5	1	6	8	4	9	1	8	4";

void main()
{
	writeln("Part One: ", solve(INPUT));
	writeln("Part Two: ", solve(INPUT, DoPartTwo.yes));
}

int solve(const(char)[] input, Flag!"partTwo" doPartTwo = DoPartTwo.no)
{
	import std.algorithm : splitter, map, joiner, reduce;
	import std.conv      : to;
	import std.array     : array;
	import std.ascii     : isWhite;

	auto banks 					= input.splitter!isWhite.map!(to!int).array;
	bool[string] knownConfigs   = ["dummy": false]; // Pretty sure using hashes to lookup configs will be faster than a linear search, in the long run (I hope, profiling be damned for this).
	string partTwoBankConfig; // Used for Part two

	string getConfigString()
	{
		return banks.map!(to!(char[])).joiner(" ").array.to!string;
	}

	// Returns: true if the config already exists or not.
	bool saveConfig()
	{
		auto config = getConfigString();

		if((config in knownConfigs) !is null)
			return true;

		knownConfigs[config] = true; // the bool is just a dummy, all I care about is being able to do "x in knownConfigs".
		return false;
	}

	/// Returns: Index of the largest bank
	size_t findLargestIndex()
	{
		size_t earliestBank = 0;
		foreach(i; 0..banks.length)
		{
			if(banks[i] > banks[earliestBank])
				earliestBank = i;
		}

		return earliestBank;
	}

	// Save the initial config
	saveConfig();

	auto redistribCount = 0;
	auto partTwoCount = 0;
	while(true)
	{
		auto largest = findLargestIndex();
		auto amount  = banks[largest];
		banks[largest] = 0;

		auto index = (largest == banks.length - 1) ? 0 : largest + 1; // Name change for clarity, also circular index.
		foreach(i; 0..amount)
		{
			banks[index] += 1;
			index = (index == banks.length - 1) ? 0 : index + 1;
		}

		redistribCount += 1;
		if(doPartTwo && (partTwoBankConfig !is null))
			partTwoCount += 1;

		bool isConfigKnown = saveConfig(); // Storing in a variable for clarity of return value.
		//writefln("%s | Count1: %s | Count2: %s | BankConfig: %s | P2Config: %s | ConfigKnown: %s", banks, redistribCount, partTwoCount, getConfigString, partTwoBankConfig, isConfigKnown);
		if(isConfigKnown)
		{
			if(doPartTwo)
			{
				if(partTwoBankConfig is null)
				{
					partTwoBankConfig = getConfigString();
					continue;
				}
				else
				{
					auto config = getConfigString();
					if(config == partTwoBankConfig)
						return partTwoCount;
				}
			}
			else
				break;
		}
	}

	return redistribCount;
}
///
unittest
{
	import std.conv;

	assert(solve("0 2 7 0") == 5);
	assert(solve("0 2 7 0", DoPartTwo.yes) == 4, solve("0 2 7 0", DoPartTwo.yes).to!string);
}