# d96assign

This package assigns kindergarten students to schools by minimizing total walking distance subject to constraints on school capacities.

Dennis Fetterly came up with this approach for the Belmont-Redwood Shores school district in Silicon Valley. Dennis shared his ideas with me (Jeff Miller) and gave me a copy of his C# code. This package and the associate Shiny application, 'StudentAssign', is an implementation of Dennis's idea in R. It uses two key R packages: ggmap (to get walking distances from Google) and lpSolve (to figure out the optimal assignment). Sam Buttery, who maintains the R lpSolve package, helped me figure out how to call the integer programming optimizer in that package.

The idea behind the assignments is extremely simple - assign students to the school to which they live closest, to the extent that this is possible.

There are two steps in the algorithm. First, the application gets the walking distance for each kindergarten student to each school. For District 96, this means getting four walking distances for each student: the distance to Ames, the distance to Blythe, the distance to Central, and the distance to Hollywood. Dennis Fetterly used Microsoft's Bing API and I am using Google (via the ggmap package) to get these distances.

Second, once it has these distances, the application minimizes the total walking distance for all students subject to the following constraints: each student is assigned to one school; each student that has an older sibling in an elementary school is assigned to the same school as the older sibling; and the total number of kindergarten students at each school falls between the minimum and maximum number of students that can be accommodated at that school (as specified by the district administration).
