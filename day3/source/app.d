import std.stdio;

const INPUT = 277678;

struct Point
{
	int x;
	int y;
}

void main()
{
	auto location = findLocation(INPUT);
	auto distance = manhattenDistance(Point(0, 0), location);
	writeln("Part One Answer: ", distance);

	// Part Two = Pure evil.
	partTwoMain();
}

int manhattenDistance(Point p1, Point p2)
{
	import std.math : abs;
	return abs(p1.x - p2.x) + abs(p1.y - p2.y);
}
///
unittest
{
	assert(manhattenDistance(Point(3, 4), Point(4, 3)) == 2);
}

Point findLocation(int number)
out(res)
{
	writeln("\tResult: ", res);
}
body
{
	import std.math : ceil, abs;

	writeln("Calculating location for number: ", number);

	assert(number >= 1);
	if(number == 1)
		return Point(0, 0); // 1 is at 0,0, anything to the left and top is negative, anything to the right and under is positive.

	// Each 'inner' square contains 8 * n numbers, where 'n' is the 'counter' of the square.
	// e.g. the first inner square, closest to 0,0 has an 'n' of 1
	// The second inner square has an 'n' of 2, etc.

	auto squareIndex = 0;
	auto lastNumberInSquare = 1;
	while(number > lastNumberInSquare)
	{
		squareIndex++;
		lastNumberInSquare += (8 * squareIndex);
	}

	writefln("\tLast number in square #%s is '%s'", squareIndex, lastNumberInSquare);

	// The last number's coordinate is always (n, n), where 'n' is the square's index.
	// We can use this later on to figure out the coordinate of our desired number
	auto lastNumberPoint = Point(squareIndex, squareIndex);
	writefln("\tLast number's point is %s", lastNumberPoint);

	// Here we figure out the min and max coordinates for the square, to make some things easier.
	auto maxPoint = Point(squareIndex, squareIndex);
	auto minPoint = Point(squareIndex, squareIndex - 1);

	// Also figure out the points for all 4 corners of the square, in case I need them.
	auto bottomRightPoint = maxPoint;
	auto bottomLeftPoint  = Point(-maxPoint.x, maxPoint.y);
	auto topLeftPoint     = Point(-maxPoint.x, -maxPoint.y);
	auto topRightPoint    = Point(maxPoint.x,  -maxPoint.y);

	writefln("\tMin: %s | Max: %s", minPoint, maxPoint);
	writefln("\tBotRight: %s | BotLeft: %s", bottomRightPoint, bottomLeftPoint);
	writefln("\tTopRight: %s | TopLeft: %s", topRightPoint, topLeftPoint);

	// Next, we'll figure out *what* numbers all of the corners are.

	// @@TODO:@@ Rename this variable, it's actually incorrect.
	auto numbersInRowColumn = (squareIndex * 2); // how many numbers are in each row and column of the square. (Technically I should add +1 to it, but for the calculation I need it for it goes one over)
	auto bottomRightNumber = lastNumberInSquare;
	auto bottomLeftNumber  = lastNumberInSquare - numbersInRowColumn;
	auto topLeftNumber     = bottomLeftNumber - numbersInRowColumn;
	auto topRighNumber     = topLeftNumber - numbersInRowColumn;

	writefln("\tBotRightNum: %s | BotLeftNum: %s", bottomRightNumber, bottomLeftNumber);
	writefln("\tTopRightNum: %s | TopLeftNum: %s", topRighNumber, topLeftNumber);

	// *Finally* we can get to working out where our number is
	// First, let's see if any of the corners are our number
	if(bottomRightNumber == number) return bottomRightPoint;
	if(bottomLeftNumber == number)  return bottomLeftPoint;
	if(topLeftNumber == number)     return topLeftPoint;
	if(topRighNumber == number)     return topRightPoint;

	// Then, we can see which range of numbers our desired number is in, and then get it's position from there.
	if(number > bottomLeftNumber) return Point(bottomLeftPoint.x + (number - bottomLeftNumber), bottomLeftPoint.y);
	if(number > topLeftNumber)    return Point(topLeftPoint.x, 									topLeftPoint.y + (number - topLeftNumber));
	if(number > topRighNumber)    return Point(topRightPoint.x - abs(number - topRighNumber), 	topRightPoint.y);
	if(number < topRighNumber)    return Point(topRightPoint.x, 								topRightPoint.y + abs(number - topRighNumber));

	assert(false);
}
///
unittest
{
	struct Test
	{
		int num;
		Point expected;
	}

	auto tests =
	[
		// Inner square #1
		Test(2, Point(1, 0)),
		Test(3, Point(1, -1)),
		Test(4, Point(0, -1)),
		Test(5, Point(-1, -1)),
		Test(6, Point(-1, 0)),
		Test(7, Point(-1, 1)),
		Test(8, Point(0, 1)),
		Test(9, Point(1, 1)),

		// Inner square #2
		Test(10, Point(2, 1)),
		Test(11, Point(2, 0)),
		Test(12, Point(2, -1)),
		Test(13, Point(2, -2)),
		Test(14, Point(1, -2)),
		Test(15, Point(0, -2)),
		Test(16, Point(-1, -2)),
		Test(17, Point(-2, -2)),
		Test(18, Point(-2, -1)),
		Test(19, Point(-2, 0)),
		Test(20, Point(-2, 1)),
		Test(21, Point(-2, 2)),
		Test(22, Point(-1, 2)),
		Test(23, Point(0, 2)),
		Test(24, Point(1, 2)),
		Test(25, Point(2, 2)),

		// Inner square #3
		Test(26, Point(3, 2))
	];

	foreach(test; tests)
	{
		import std.format;
		auto got = findLocation(test.num);
		assert(got == test.expected, format("Got: %s | Expected: %s | for number: %s", got, test.expected, test.num));
	}
}

/** Part Two stuff **/

enum Target
{
	TopRight,
	TopLeft,
	BottomLeft,
	BottomRight,
	Done
}

void partTwoMain()
{
	writeln("Part Two Answer = ", doPartTwo(INPUT));
}

int doPartTwo(int target)
{
	writeln("Solving Part Two with a target of: ", target);

	int[Point] numbers;
	numbers[Point(0, 0)] = 1;

	auto squareIndex = 0;
	auto numberIndex = Point(1, 1); // We start at Y:1 because the algorithm will bump it up to 0 for us. If we didn't do this thenn it'd completely skip a number
	const initialNumbersPerRowColumn = 3; // Each row and column have 3 numbers to start off with
	const numbersPerRowColumnIncrease = 2; // And grow by 2 everytime the square grows
	while(true)
	{
		squareIndex++;
		auto numbersInSquare     = (squareIndex * 8);
		auto numbersPerRowColumn = (initialNumbersPerRowColumn + (numbersPerRowColumnIncrease * (squareIndex - 1)));
		auto lastPointInSquare   = Point(squareIndex, squareIndex);

		writeln("\tCurrently solving Square #", squareIndex);
		writefln("\t\tNumbers in square = %s", numbersInSquare);
		writefln("\t\tNumbers per row and column = %s", numbersPerRowColumn);
		writefln("\t\tLast point in square = %s", lastPointInSquare);

		auto maxPoint = lastPointInSquare;
		auto bottomRightPoint = maxPoint;
		auto bottomLeftPoint  = Point(-maxPoint.x, maxPoint.y);
		auto topLeftPoint     = Point(-maxPoint.x, -maxPoint.y);
		auto topRightPoint    = Point(maxPoint.x,  -maxPoint.y);

		auto currentTarget = Target.TopRight;
		while(currentTarget != Target.Done)
		{
			// Get the next position to add in a number (and update the target point as neccessary).
			final switch(currentTarget) with(Target)
			{
				case TopRight:
					if(numberIndex == topRightPoint)
					{
						currentTarget = TopLeft;
						continue;
					}

					numberIndex.y -= 1;
					break;

				case TopLeft:
					if(numberIndex == topLeftPoint)
					{
						currentTarget = BottomLeft;
						continue;
					}

					numberIndex.x -= 1;
					break;

				case BottomLeft:
					if(numberIndex == bottomLeftPoint)
					{
						currentTarget = BottomRight;
						continue;
					}

					numberIndex.y += 1;
					break;

				case BottomRight:
					if(numberIndex == bottomRightPoint)
					{
						numberIndex.x += 1; // So it starts in the right position
						numberIndex.y += 1;
						currentTarget = Done;
						continue;
					}

					numberIndex.x += 1;
					break;

				case Done: assert(false);
			}

			writefln("\t\tCurrent point = %s and current target = %s", numberIndex, currentTarget);
			
			int getNumberAtPosition(int xOffset, int yOffset)
			{
				auto numPtr = (Point(numberIndex.x + xOffset, numberIndex.y + yOffset) in numbers);
				return (numPtr is null) ? 0 : *numPtr;
			}

			// Add up all neighbouring numbers
			// Positions are relative to numberIndex
			// None existing numbers return 0
			auto sum =  getNumberAtPosition(-1, -1);
				 sum += getNumberAtPosition(0, -1);
				 sum += getNumberAtPosition(1, -1);
				 sum += getNumberAtPosition(-1, 0);
				 sum += getNumberAtPosition(1, 0); // we skip 0, 0 for obvious reasons.
				 sum += getNumberAtPosition(-1, 1);
				 sum += getNumberAtPosition(0, 1);
				 sum += getNumberAtPosition(1, 1);

			numbers[numberIndex] = sum;
			writefln("\t\t\tPoint at %s has a value of %s", numberIndex, sum);

			if(sum > target)
				return sum;
		}
	}

	assert(false);
}