## Navigation model

FHIRPath navigates and selects nodes from a tree that abstracts away and is independent of the actual underlying implementation of the source against which the FHIRPath query is run. This way, FHIRPath can be used on in-memory Java POJOs, Xml data or any other physical representation, so long as that representation can be viewed as classes that have properties. In somewhat more formal terms, FHIRPath operates on a directed acyclic graph of classes as defined by a MOF-equivalent [MOF](#MOF) type system.

Data are represented as a tree of labelled nodes, where each node may optionally carry a primitive value and have child nodes. Nodes need not have a unique label, and leaf nodes must carry a primitive value. For example, a (partial) representation of a FHIR Patient resource in this model looks like this:

!["Tree representation of a Patient"](treestructure.png)

The diagram shows a tree with a repeating `name` node, which represents repeating members of the FHIR object model. Leaf nodes such as `use` and `family` carry a (string) value. It is also possible for internal nodes to carry a value, as is the case for the node labelled `active`: this allows the tree to represent FHIR "primitives", which may still have child extension data.

FHIRPath expressions are then _evaluated_ with respect to a specific instance, such as the Patient one described above. This instance is referred to as the _context_ (also called the _root_) and paths within the expression are evaluated in terms of this instance.