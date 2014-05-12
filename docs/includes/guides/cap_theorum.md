##CAP Theorum

<div id="cap_theorem"></div>

Developers early in the design process might want to consider the complexities raised by [The CAP theorem](http://lpd.epfl.ch/sgilbert/pubs/BrewersConjecture-SigAct.pdf), which states that a distributed computing system can only exhibit two of the three following characteristics:

* Consistency: all nodes see the same data at the same time.
* Availability: every request receives a response indicating success or failure.
* Partition Tolerance: the system continues to operate despite arbitrary message loss or failure of part of the system.

For example, a database prioritizing consistency and availability is simple: a single node storing a single copy of your data. But scaling necessarily involves a performance increase in the node rather than the leverage of additional nodes, which means that a minor system failure can shut down a single-node system. To endure, the system must become more sophisticated. Cloudant's ease of scalability makes it adaptable to this problem.
