import std.stdio;

const INPUT = "76,1,88,148,166,217,130,0,128,254,16,2,130,71,255,229";

void main()
{
    import std.conv : to;
    import std.algorithm : map, joiner;
    import std.array : array;
    import std.string : rightJustify;
    import std.uni : toLower;

    auto list = doHash(INPUT);
    //writeln(list);
    writeln("Part One: ", list[0] * list[1]);

    list = doHash(INPUT, true);
    auto hash = list.createDenseHash();
    
    auto hex = hash.map!(n => n.to!string(16).rightJustify(2, '0').toLower)
                   .joiner
                   .array;

    assert(hex.length == 32);
    writeln("Part Two: ", hex);
}

int[] doHash(const(char)[] lengths, bool doPartTwo = false)
{
    import std.range     : iota, chain;
    import std.array     : array;
    import std.algorithm : splitter, map;
    import std.conv      : to;

    auto position = 0u;
    auto skip = 0;
    auto list = iota(0, 256).array;
    assert(list[$-1] == 255);

    if(!doPartTwo)
    {
        doRound(list, position, skip, lengths.splitter(',').map!(to!int));
    }
    else
    {
        foreach(i; 0..64)
        {
            doRound(list, position, skip, chain(lengths.map!(to!int), [17, 31, 73, 47, 23]));
        }
    }

    return list;
}

void doRound(R)(ref int[] list, ref uint position, ref int skip, R lengths)
{
    foreach(length; lengths)
    {
        auto start = position; // To compliment 'end' below
        auto end = position + length;
        auto difference = length;
        if((difference % 2) == 1) difference -= 1;

        foreach(i; 0..difference / 2)
        {
            auto startIndex = start + i;
            auto endIndex = end - (i + 1); // 0-based, have to remove 1 always.

            while(startIndex >= list.length) startIndex -= list.length;
            while(endIndex >= list.length)   endIndex -= list.length;

            //debug writefln("Start: %s | End: %s | StartI: %s | EndI: %s", start, end, startIndex, endIndex);

            auto temp = list[startIndex];
            list[startIndex] = list[endIndex];
            list[endIndex] = temp;
        }

        position += length + skip;
        skip += 1;

        while(position >= list.length)
            position = (position - list.length);
    }
}

byte[] createDenseHash(int[] list)
{
    assert(list.length == 256);
    auto hash = new byte[16];

    foreach(i; 0..16)
    {
        //debug writefln("Block #%s: %s", i, list[(16 * i)..(16 * i) + 16]);
        foreach(num; list[(16 * i)..(16 * i) + 16])
        {
            hash[i] ^= num;
        }
        //debug writefln("\tHash: %s", hash[i]);
    }

    return hash;
}