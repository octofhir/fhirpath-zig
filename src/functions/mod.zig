// Function module exports
pub const collection = @import("collection.zig");
pub const string = @import("string.zig");
pub const boolean = @import("boolean.zig");
pub const conversion = @import("conversion.zig");
pub const type_reflection = @import("type_reflection.zig");
pub const datetime = @import("datetime.zig");
pub const math = @import("math.zig");
pub const aggregate = @import("aggregate.zig");
pub const utility = @import("utility.zig");

// Import for convenience
const EvaluationContext = @import("../evaluator.zig").EvaluationContext;

// Function type
pub const BuiltinFunction = *const fn (context: *EvaluationContext, args: []@import("../types.zig").Value) anyerror!@import("../types.zig").Value;

// Function registry helper
pub fn registerAllFunctions(functions: *@import("std").HashMap([]const u8, BuiltinFunction, @import("std").hash_map.StringContext, @import("std").hash_map.default_max_load_percentage)) !void {
    // Collection functions
    try functions.put("empty", collection.empty);
    try functions.put("exists", collection.exists);
    try functions.put("count", collection.count);
    try functions.put("first", collection.first);
    try functions.put("last", collection.last);
    try functions.put("single", collection.single);
    try functions.put("distinct", collection.distinct);
    try functions.put("where", collection.where);
    try functions.put("select", collection.select);
    try functions.put("tail", collection.tail);
    try functions.put("skip", collection.skip);
    try functions.put("take", collection.take);
    try functions.put("union", collection.unionFn);
    try functions.put("intersect", collection.intersect);
    try functions.put("exclude", collection.exclude);
    try functions.put("isDistinct", collection.isDistinct);
    try functions.put("combine", collection.combine);
    try functions.put("subsetOf", collection.subsetOf);
    try functions.put("supersetOf", collection.supersetOf);
    try functions.put("distinctBy", collection.distinctBy);
    
    // String functions
    try functions.put("length", string.length);
    try functions.put("substring", string.substring);
    try functions.put("contains", string.contains);
    try functions.put("startsWith", string.startsWith);
    try functions.put("endsWith", string.endsWith);
    try functions.put("indexOf", string.indexOf);
    try functions.put("upper", string.upper);
    try functions.put("lower", string.lower);
    try functions.put("replace", string.replace);
    try functions.put("matches", string.matches);
    
    // Boolean functions
    try functions.put("not", boolean.not);
    
    // Conversion functions
    try functions.put("convertsToInteger", conversion.convertsToInteger);
    try functions.put("convertsToDecimal", conversion.convertsToDecimal);
    try functions.put("convertsToBoolean", conversion.convertsToBoolean);
    try functions.put("convertsToString", conversion.convertsToString);
    try functions.put("convertsToQuantity", conversion.convertsToQuantity);
    try functions.put("toInteger", conversion.toInteger);
    try functions.put("toDecimal", conversion.toDecimal);
    try functions.put("toBoolean", conversion.toBoolean);
    try functions.put("toString", conversion.toString);
    
    // Type reflection functions
    try functions.put("is", type_reflection.isFn);
    try functions.put("as", type_reflection.asFn);
    try functions.put("ofType", type_reflection.ofType);
    try functions.put("type", type_reflection.typeFn);
    
    // Date/time functions
    try functions.put("today", datetime.today);
    try functions.put("now", datetime.now);
    try functions.put("timeOfDay", datetime.timeOfDay);
    
    // Math functions
    try functions.put("abs", math.abs);
    try functions.put("ceiling", math.ceiling);
    try functions.put("floor", math.floor);
    try functions.put("truncate", math.truncate);
    try functions.put("round", math.round);
    try functions.put("sqrt", math.sqrt);
    try functions.put("exp", math.exp);
    try functions.put("ln", math.ln);
    try functions.put("log", math.log);
    try functions.put("power", math.power);
    
    // Aggregate functions
    try functions.put("sum", aggregate.sum);
    try functions.put("min", aggregate.min);
    try functions.put("max", aggregate.max);
    try functions.put("avg", aggregate.avg);
    try functions.put("stdDev", aggregate.stdDev);
    try functions.put("variance", aggregate.variance);
    try functions.put("aggregate", aggregate.aggregate);
    
    // Utility functions
    try functions.put("trace", utility.trace);
    try functions.put("repeat", utility.repeat);
    try functions.put("iif", utility.iif);
}