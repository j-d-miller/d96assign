# d96assign

This package assigns kindergarten students to schools by minimizing total walking distance subject to constraints on school capacities.

Dennis Fetterly came up with this approach for the Belmont-Redwood Shores school district in Silicon Valley. Dennis shared his ideas with me (Jeff Miller) and gave me a copy of his C# code. This package and the associated Shiny application, 'StudentAssign', is an implementation of Dennis's idea in R for District 96 in suburban Cook County. It relies on two key R packages: ggmap (to get the walking distances from students' homes to each school) and lpSolve (to figure out the optimal assignment of students to schools). Sam Buttery, who maintains the R lpSolve package, helped me figure out how to call the mixed integer programming optimizer in the lpSolve package.

The idea behind the assignments is simple - assign students to the school to which they live closest, to the extent that this is possible. 

There are two steps in the algorithm. First, the application gets the walking distance for each kindergarten student to each school. For District 96, this means getting four walking distances for each student: the distance to Ames, the distance to Blythe, the distance to Central, and the distance to Hollywood. Dennis Fetterly used Microsoft's Bing API, while I use the Google API (via the ggmap package) to get these distances.

Second, once it has all the walking distances, the application uses mixed integer linear programming to minimize the total (or average) student walking distance subject to several constraints. The important constraints are that each student who has an older sibling in an elementary school be assigned to the same school as the older sibling; and that the total number of kindergarten students assigned to each school fall between the minimum and maximum number of students that can be accommodated at that school (as specified by the district administration).
