const std = @import("std");
const ast = @import("ast.zig");
const types = @import("types.zig");
const functions = @import("functions/mod.zig");

// Function signature for built-in functions
pub const BuiltinFunction = *const fn (context: *EvaluationContext, args: []types.Value) anyerror!types.Value;

// Evaluation context holds variables, functions, and the current resource
pub const EvaluationContext = struct {
    allocator: std.mem.Allocator,
    // Current FHIR resource being evaluated (JSON-like structure)
    resource: ?std.json.Value = null,
    // Variable bindings ($this, $index, $total, etc.)
    variables: std.HashMap([]const u8, types.Value, std.hash_map.StringContext, std.hash_map.default_max_load_percentage),
    // Function registry
    functions: std.HashMap([]const u8, BuiltinFunction, std.hash_map.StringContext, std.hash_map.default_max_load_percentage),
    // Current context path (for error reporting)
    current_path: std.ArrayList([]const u8),
    
    pub fn init(allocator: std.mem.Allocator) EvaluationContext {
        var context = EvaluationContext{
            .allocator = allocator,
            .resource = null,
            .variables = std.HashMap([]const u8, types.Value, std.hash_map.StringContext, std.hash_map.default_max_load_percentage).init(allocator),
            .functions = std.HashMap([]const u8, BuiltinFunction, std.hash_map.StringContext, std.hash_map.default_max_load_percentage).init(allocator),
            .current_path = std.ArrayList([]const u8).init(allocator),
        };
        
        // Register built-in functions
        context.registerBuiltinFunctions() catch {};
        
        return context;
    }
    
    pub fn deinit(self: *EvaluationContext) void {
        self.variables.deinit();
        self.functions.deinit();
        self.current_path.deinit();
    }
    
    pub fn setResource(self: *EvaluationContext, resource: std.json.Value) void {
        self.resource = resource;
    }
    
    pub fn setVariable(self: *EvaluationContext, name: []const u8, value: types.Value) !void {
        const owned_name = try self.allocator.dupe(u8, name);
        try self.variables.put(owned_name, value);
    }
    
    pub fn getVariable(self: *EvaluationContext, name: []const u8) ?types.Value {
        return self.variables.get(name);
    }
    
    pub fn getFunction(self: *EvaluationContext, name: []const u8) ?BuiltinFunction {
        return self.functions.get(name);
    }
    
    fn registerBuiltinFunctions(self: *EvaluationContext) !void {
        try functions.registerAllFunctions(&self.functions);
    }
};

// Helper function for value equality comparison
fn equalValues(left: types.Value, right: types.Value) bool {
    return switch (left) {
            .boolean => |l_val| switch (right) {
                .boolean => |r_val| l_val == r_val,
                else => false,
            },
            .integer => |l_val| switch (right) {
                .integer => |r_val| l_val == r_val,
                .decimal => |r_val| @as(f64, @floatFromInt(l_val)) == r_val,
                else => false,
            },
            .decimal => |l_val| switch (right) {
                .integer => |r_val| l_val == @as(f64, @floatFromInt(r_val)),
                .decimal => |r_val| l_val == r_val,
                else => false,
            },
            .string => |l_val| switch (right) {
                .string => |r_val| std.mem.eql(u8, l_val, r_val),
                else => false,
            },
            .date => |l_val| switch (right) {
                .date => |r_val| l_val.year == r_val.year and l_val.month == r_val.month and l_val.day == r_val.day,
                else => false,
            },
            .time => |l_val| switch (right) {
                .time => |r_val| l_val.hour == r_val.hour and l_val.minute == r_val.minute and l_val.second == r_val.second and l_val.millisecond == r_val.millisecond,
                else => false,
            },
            .date_time => |l_val| switch (right) {
                .date_time => |r_val| {
                    const dates_equal = l_val.date.year == r_val.date.year and
                        l_val.date.month == r_val.date.month and
                        l_val.date.day == r_val.date.day;
                    const times_equal = if (l_val.time != null and r_val.time != null)
                        l_val.time.?.hour == r_val.time.?.hour and
                            l_val.time.?.minute == r_val.time.?.minute and
                            l_val.time.?.second == r_val.time.?.second and
                            l_val.time.?.millisecond == r_val.time.?.millisecond
                    else
                        l_val.time == null and r_val.time == null;
                    return dates_equal and times_equal;
                },
                else => false,
            },
            .quantity => |l_val| switch (right) {
                .quantity => |r_val| {
                    // For basic comparison, values and units must match exactly
                    const values_equal = l_val.value == r_val.value;
                    const units_equal = if (l_val.unit == null and r_val.unit == null)
                        true
                    else if (l_val.unit != null and r_val.unit != null)
                        std.mem.eql(u8, l_val.unit.?, r_val.unit.?)
                    else
                        false;
                    return values_equal and units_equal;
                },
                else => false,
            },
            .null_value => switch (right) {
                .null_value => true,
                else => false,
            },
            .collection => |l_coll| switch (right) {
                .collection => |r_coll| {
                    if (l_coll.len != r_coll.len) return false;
                    for (l_coll, r_coll) |l_item, r_item| {
                        if (!equalValues(l_item, r_item)) return false;
                    }
                    return true;
                },
                else => false,
            },
            .json_object => false, // JSON objects are not directly comparable
        };
}

// Helper function to convert values to boolean
fn toBoolValue(value: types.Value) bool {
    return switch (value) {
        .boolean => |val| val,
        .integer => |val| val != 0,
        .decimal => |val| val != 0.0,
        .string => |val| val.len > 0,
        .date, .time, .date_time => true,
        .quantity => |val| val.value != 0.0,
        .collection => |coll| {
            if (coll.len == 0) return false;
            if (coll.len == 1) {
                // For single-item collections, get the boolean value of the item
                return toBoolValue(coll[0]);
            }
            // Multiple items - collection is truthy
            return true;
        },
        .json_object => true, // JSON objects are considered truthy
        .null_value => false,
    };
}

// Helper function to wrap single values in collections (FHIRPath collection semantics)
fn wrapInCollection(allocator: std.mem.Allocator, value: types.Value) !types.Value {
    switch (value) {
        .collection => return value, // Already a collection
        else => {
            const collection = try allocator.alloc(types.Value, 1);
            collection[0] = value;
            return types.Value{ .collection = collection };
        }
    }
}



// Evaluator - enhanced implementation with proper context support
pub const Evaluator = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Evaluator {
        return Evaluator{
            .allocator = allocator,
        };
    }

    pub fn evaluate(self: *Evaluator, node: *ast.Node, context: *EvaluationContext) anyerror!types.Value {
        return switch (node.node_type) {
            .literal => {
                const literal = node.cast(ast.LiteralNode).?;
                
                // All FHIRPath expressions return collections, even single values
                const single_value = switch (literal.value) {
                    .boolean => |val| types.Value{ .boolean = val },
                    .integer => |val| types.Value{ .integer = val },
                    .decimal => |val| types.Value{ .decimal = val },
                    .string => |val| types.Value{ .string = val },
                    .date => |val| types.Value{ .date = val },
                    .time => |val| types.Value{ .time = val },
                    .date_time => |val| types.Value{ .date_time = val },
                    .quantity => |val| types.Value{ .quantity = val },
                    .null_value => types.Value{ .null_value = {} },
                };
                
                // Wrap single value in a collection
                const collection = try self.allocator.alloc(types.Value, 1);
                collection[0] = single_value;
                return types.Value{ .collection = collection };
            },
            .identifier => {
                const identifier = node.cast(ast.IdentifierNode).?;
                
                // Check if it's a variable ($this, $index, etc.)
                if (context.getVariable(identifier.name)) |variable| {
                    // Variables should already be collections, but wrap if not
                    switch (variable) {
                        .collection => return variable,
                        else => {
                            const collection = try self.allocator.alloc(types.Value, 1);
                            collection[0] = variable;
                            return types.Value{ .collection = collection };
                        }
                    }
                }
                
                // Check if it's the root resource
                if (context.resource) |resource| {
                    return try self.accessProperty(resource, identifier.name, context);
                }
                
                // Fallback: return empty collection for unresolved identifiers
                return types.Value{ .collection = &[_]types.Value{} };
            },
            .binary_op => {
                const binary = node.cast(ast.BinaryOpNode).?;
                const left = try self.evaluate(binary.left, context);
                const right = try self.evaluate(binary.right, context);

                switch (binary.operator) {
                    .plus => return try self.addValues(left, right),
                    .minus => return try self.subtractValues(left, right),
                    .star => return try self.multiplyValues(left, right),
                    .slash => return try self.divideValues(left, right),
                    .percent => return try self.modValues(left, right),
                    .div => return try self.divIntValues(left, right),
                    .equal => return try self.equalityComparison(left, right, true),
                    .not_equal => return try self.equalityComparison(left, right, false),
                    .less => return try self.compareValues(left, right, .less),
                    .less_equal => return try self.compareValues(left, right, .less_equal),
                    .greater => return try self.compareValues(left, right, .greater), 
                    .greater_equal => return try self.compareValues(left, right, .greater_equal),
                    .equivalent => return try self.equivalentValues(left, right),
                    .not_equivalent => {
                        const equiv_result = try self.equivalentValues(left, right);
                        const boolean_value = if (equiv_result.collection.len > 0) equiv_result.collection[0].boolean else false;
                        return try wrapInCollection(self.allocator, types.Value{ .boolean = !boolean_value });
                    },
                    .and_op => return try self.andValues(left, right),
                    .or_op => return try self.orValues(left, right),
                    .xor_op => return try self.xorValues(left, right),
                    .implies => return try self.impliesValues(left, right),
                    else => return error.UnsupportedOperation,
                }
            },
            .unary_op => {
                const unary = node.cast(ast.UnaryOpNode).?;
                const operand = try self.evaluate(unary.operand, context);

                switch (unary.operator) {
                    .not_op => return try wrapInCollection(self.allocator, types.Value{ .boolean = !toBoolValue(operand) }),
                    .minus => {
                        const result = switch (operand) {
                            .integer => |val| types.Value{ .integer = -val },
                            .decimal => |val| types.Value{ .decimal = -val },
                            else => return error.TypeMismatch,
                        };
                        return try wrapInCollection(self.allocator, result);
                    },
                    .plus => {
                        const result = switch (operand) {
                            .integer, .decimal => operand, // Positive unary is identity
                            else => return error.TypeMismatch,
                        };
                        return try wrapInCollection(self.allocator, result);
                    },
                    else => return error.UnsupportedOperation,
                }
            },
            .member_access => {
                const member = node.cast(ast.MemberAccessNode).?;
                const object_value = try self.evaluate(member.object, context);
                
                // Handle path navigation based on object type
                return try self.navigateProperty(object_value, member.property, context);
            },
            .function_call => {
                const function_call = node.cast(ast.FunctionCallNode).?;
                const function_name = function_call.function_name;

                // Look up function in registry
                if (context.getFunction(function_name)) |func| {
                    // Evaluate arguments
                    var args = try self.allocator.alloc(types.Value, function_call.arguments.len);
                    defer self.allocator.free(args);
                    
                    for (function_call.arguments, 0..) |arg_node, i| {
                        args[i] = try self.evaluate(arg_node, context);
                    }
                    
                    return try func(context, args);
                } else {
                    return error.UnsupportedOperation;
                }
            },
            .indexer => {
                const indexer = node.cast(ast.IndexerNode).?;
                const object_value = try self.evaluate(indexer.object, context);
                const index_value = try self.evaluate(indexer.index, context);
                
                return try self.indexCollection(object_value, index_value, context);
            },
            .collection => {
                const collection_node = node.cast(ast.CollectionNode).?;
                
                // Evaluate each element in the collection
                var results = std.ArrayList(types.Value).init(self.allocator);
                defer results.deinit();
                
                for (collection_node.elements) |element| {
                    const element_value = try self.evaluate(element, context);
                    // Flatten collections - each element is already wrapped in a collection
                    switch (element_value) {
                        .collection => |coll| try results.appendSlice(coll),
                        else => try results.append(element_value),
                    }
                }
                
                return types.Value{ .collection = try results.toOwnedSlice() };
            },
            else => error.NotImplemented,
        };
    }

    // Property navigation for FHIR resources and objects
    fn navigateProperty(self: *Evaluator, object: types.Value, property: []const u8, context: *EvaluationContext) !types.Value {
        switch (object) {
            .json_object => |json| {
                // Navigate into JSON objects
                return try self.accessProperty(json, property, context);
            },
            .collection => |coll| {
                // Apply property navigation to each item in collection
                var results = std.ArrayList(types.Value).init(self.allocator);
                defer results.deinit();
                
                for (coll) |item| {
                    const result = try self.navigateProperty(item, property, context);
                    switch (result) {
                        .collection => |inner_coll| {
                            // Always append collection contents, even if empty (empty collections are valid in FHIRPath)
                            try results.appendSlice(inner_coll);
                        },
                        else => try results.append(result),
                    }
                }
                
                return types.Value{ .collection = try results.toOwnedSlice() };
            },
            else => {
                // For non-collection values, return empty collection since we can't navigate properties on them
                return types.Value{ .collection = &[_]types.Value{} };
            },
        }
    }
    
    // JSON property access
    fn accessProperty(self: *Evaluator, json: std.json.Value, property: []const u8, context: *EvaluationContext) !types.Value {
        
        switch (json) {
            .object => |obj| {
                if (obj.get(property)) |value| {
                    return try self.jsonToValue(value);
                }
                return types.Value{ .collection = &[_]types.Value{} };
            },
            .array => |arr| {
                var results = std.ArrayList(types.Value).init(self.allocator);
                defer results.deinit();
                
                for (arr.items) |item| {
                    const result = try self.accessProperty(item, property, context);
                    switch (result) {
                        .collection => |coll| try results.appendSlice(coll),
                        else => try results.append(result),
                    }
                }
                
                return types.Value{ .collection = try results.toOwnedSlice() };
            },
            else => return types.Value{ .collection = &[_]types.Value{} },
        }
    }
    
    // Convert JSON value to FHIRPath Value
    fn jsonToValue(self: *Evaluator, json: std.json.Value) !types.Value {
        return switch (json) {
            .null => types.Value{ .collection = &[_]types.Value{} }, // FHIRPath has no null - return empty collection
            .bool => |val| types.Value{ .boolean = val },
            .integer => |val| types.Value{ .integer = val },
            .float => |val| types.Value{ .decimal = val },
            .number_string => |val| {
                // Try to parse as integer first, then as decimal
                if (std.fmt.parseInt(i64, val, 10)) |int_val| {
                    return types.Value{ .integer = int_val };
                } else |_| {
                    if (std.fmt.parseFloat(f64, val)) |float_val| {
                        return types.Value{ .decimal = float_val };
                    } else |_| {
                        return types.Value{ .string = val };
                    }
                }
            },
            .string => |val| types.Value{ .string = val },
            .array => |arr| {
                var results = try self.allocator.alloc(types.Value, arr.items.len);
                for (arr.items, 0..) |item, i| {
                    results[i] = try self.jsonToValue(item);
                }
                return types.Value{ .collection = results };
            },
            .object => |_| {
                // Preserve JSON objects so they can be navigated
                return types.Value{ .json_object = json };
            },
        };
    }
    
    // Collection indexing
    fn indexCollection(self: *Evaluator, object: types.Value, index: types.Value, context: *EvaluationContext) !types.Value {
        _ = self;
        _ = context;
        
        const idx = switch (index) {
            .integer => |val| val,
            else => return error.TypeMismatch,
        };
        
        switch (object) {
            .collection => |coll| {
                if (idx < 0 or idx >= coll.len) {
                    return types.Value{ .collection = &[_]types.Value{} };
                }
                return coll[@intCast(idx)];
            },
            .string => |str| {
                if (idx < 0 or idx >= str.len) {
                    return types.Value{ .string = "" };
                }
                const char_slice = str[@intCast(idx)..@intCast(idx + 1)];
                return types.Value{ .string = char_slice };
            },
            else => return types.Value{ .collection = &[_]types.Value{} },
        }
    }

    fn addValues(self: *Evaluator, left: types.Value, right: types.Value) !types.Value {
        // Memory cleanup handled by top-level caller
        // defer left.deinit(self.allocator);
        // defer right.deinit(self.allocator);
        
        // Extract single values from collections (FHIRPath collection semantics)
        const left_val = try self.extractSingleValue(left);
        const right_val = try self.extractSingleValue(right);
        
        const result = switch (left_val) {
            .integer => |l_val| switch (right_val) {
                .integer => |r_val| types.Value{ .integer = l_val + r_val },
                .decimal => |r_val| types.Value{ .decimal = @as(f64, @floatFromInt(l_val)) + r_val },
                else => return error.TypeMismatch,
            },
            .decimal => |l_val| switch (right_val) {
                .integer => |r_val| types.Value{ .decimal = l_val + @as(f64, @floatFromInt(r_val)) },
                .decimal => |r_val| types.Value{ .decimal = l_val + r_val },
                else => return error.TypeMismatch,
            },
            else => return error.TypeMismatch,
        };
        
        // Wrap result in collection (FHIRPath collection semantics)
        return try wrapInCollection(self.allocator, result);
    }

    // Helper method to extract single values from collections for operations
    fn extractSingleValue(self: *Evaluator, value: types.Value) !types.Value {
        _ = self;
        switch (value) {
            .collection => |coll| {
                if (coll.len == 0) return error.EmptyCollection;
                if (coll.len > 1) return error.MultipleValues;
                return coll[0];
            },
            else => return value, // Already a single value
        }
    }

    fn subtractValues(self: *Evaluator, left: types.Value, right: types.Value) !types.Value {
        // Memory cleanup handled by top-level caller
        // defer left.deinit(self.allocator);
        // defer right.deinit(self.allocator);
        
        const left_val = try self.extractSingleValue(left);
        const right_val = try self.extractSingleValue(right);
        
        const result = switch (left_val) {
            .integer => |l_val| switch (right_val) {
                .integer => |r_val| types.Value{ .integer = l_val - r_val },
                .decimal => |r_val| types.Value{ .decimal = @as(f64, @floatFromInt(l_val)) - r_val },
                else => return error.TypeMismatch,
            },
            .decimal => |l_val| switch (right_val) {
                .integer => |r_val| types.Value{ .decimal = l_val - @as(f64, @floatFromInt(r_val)) },
                .decimal => |r_val| types.Value{ .decimal = l_val - r_val },
                else => return error.TypeMismatch,
            },
            else => return error.TypeMismatch,
        };
        
        return try wrapInCollection(self.allocator, result);
    }

    fn multiplyValues(self: *Evaluator, left: types.Value, right: types.Value) !types.Value {
        // Memory cleanup handled by top-level caller
        // defer left.deinit(self.allocator);
        // defer right.deinit(self.allocator);
        
        const left_val = try self.extractSingleValue(left);
        const right_val = try self.extractSingleValue(right);
        
        const result = switch (left_val) {
            .integer => |l_val| switch (right_val) {
                .integer => |r_val| types.Value{ .integer = l_val * r_val },
                .decimal => |r_val| types.Value{ .decimal = @as(f64, @floatFromInt(l_val)) * r_val },
                else => return error.TypeMismatch,
            },
            .decimal => |l_val| switch (right_val) {
                .integer => |r_val| types.Value{ .decimal = l_val * @as(f64, @floatFromInt(r_val)) },
                .decimal => |r_val| types.Value{ .decimal = l_val * r_val },
                else => return error.TypeMismatch,
            },
            else => return error.TypeMismatch,
        };
        
        return try wrapInCollection(self.allocator, result);
    }

    fn divideValues(self: *Evaluator, left: types.Value, right: types.Value) !types.Value {
        // Memory cleanup handled by top-level caller
        // defer left.deinit(self.allocator);
        // defer right.deinit(self.allocator);
        
        const left_val = try self.extractSingleValue(left);
        const right_val = try self.extractSingleValue(right);
        
        const result = switch (left_val) {
            .integer => |l_val| switch (right_val) {
                .integer => |r_val| blk: {
                    if (r_val == 0) return error.DivisionByZero;
                    break :blk types.Value{ .decimal = @as(f64, @floatFromInt(l_val)) / @as(f64, @floatFromInt(r_val)) };
                },
                .decimal => |r_val| blk: {
                    if (r_val == 0.0) return error.DivisionByZero;
                    break :blk types.Value{ .decimal = @as(f64, @floatFromInt(l_val)) / r_val };
                },
                else => return error.TypeMismatch,
            },
            .decimal => |l_val| switch (right_val) {
                .integer => |r_val| blk: {
                    if (r_val == 0) return error.DivisionByZero;
                    break :blk types.Value{ .decimal = l_val / @as(f64, @floatFromInt(r_val)) };
                },
                .decimal => |r_val| blk: {
                    if (r_val == 0.0) return error.DivisionByZero;
                    break :blk types.Value{ .decimal = l_val / r_val };
                },
                else => return error.TypeMismatch,
            },
            else => return error.TypeMismatch,
        };
        
        return try wrapInCollection(self.allocator, result);
    }

    fn modValues(self: *Evaluator, left: types.Value, right: types.Value) !types.Value {
        // Memory cleanup handled by top-level caller
        // defer left.deinit(self.allocator);
        // defer right.deinit(self.allocator);
        
        const left_val = try self.extractSingleValue(left);
        const right_val = try self.extractSingleValue(right);
        
        const result = switch (left_val) {
            .integer => |l_val| switch (right_val) {
                .integer => |r_val| blk: {
                    if (r_val == 0) return error.DivisionByZero;
                    break :blk types.Value{ .integer = @mod(l_val, r_val) };
                },
                else => return error.TypeMismatch,
            },
            else => return error.TypeMismatch,
        };
        
        return try wrapInCollection(self.allocator, result);
    }

    fn divIntValues(self: *Evaluator, left: types.Value, right: types.Value) !types.Value {
        // Memory cleanup handled by top-level caller
        // defer left.deinit(self.allocator);
        // defer right.deinit(self.allocator);
        
        const left_val = try self.extractSingleValue(left);
        const right_val = try self.extractSingleValue(right);
        
        const result = switch (left_val) {
            .integer => |l_val| switch (right_val) {
                .integer => |r_val| blk: {
                    if (r_val == 0) return error.DivisionByZero;
                    break :blk types.Value{ .integer = @divTrunc(l_val, r_val) };
                },
                else => return error.TypeMismatch,
            },
            else => return error.TypeMismatch,
        };
        
        return try wrapInCollection(self.allocator, result);
    }

    const CompareOp = enum { less, less_equal, greater, greater_equal };

    fn compareValues(self: *Evaluator, left: types.Value, right: types.Value, op: CompareOp) !types.Value {
        const result = switch (left) {
            .integer => |l_val| switch (right) {
                .integer => |r_val| switch (op) {
                    .less => l_val < r_val,
                    .less_equal => l_val <= r_val,
                    .greater => l_val > r_val,
                    .greater_equal => l_val >= r_val,
                },
                .decimal => |r_val| switch (op) {
                    .less => @as(f64, @floatFromInt(l_val)) < r_val,
                    .less_equal => @as(f64, @floatFromInt(l_val)) <= r_val,
                    .greater => @as(f64, @floatFromInt(l_val)) > r_val,
                    .greater_equal => @as(f64, @floatFromInt(l_val)) >= r_val,
                },
                else => return error.TypeMismatch,
            },
            .decimal => |l_val| switch (right) {
                .integer => |r_val| switch (op) {
                    .less => l_val < @as(f64, @floatFromInt(r_val)),
                    .less_equal => l_val <= @as(f64, @floatFromInt(r_val)),
                    .greater => l_val > @as(f64, @floatFromInt(r_val)),
                    .greater_equal => l_val >= @as(f64, @floatFromInt(r_val)),
                },
                .decimal => |r_val| switch (op) {
                    .less => l_val < r_val,
                    .less_equal => l_val <= r_val,
                    .greater => l_val > r_val,
                    .greater_equal => l_val >= r_val,
                },
                else => return error.TypeMismatch,
            },
            .string => |l_val| switch (right) {
                .string => |r_val| switch (op) {
                    .less => std.mem.order(u8, l_val, r_val) == .lt,
                    .less_equal => std.mem.order(u8, l_val, r_val) != .gt,
                    .greater => std.mem.order(u8, l_val, r_val) == .gt,
                    .greater_equal => std.mem.order(u8, l_val, r_val) != .lt,
                },
                else => return error.TypeMismatch,
            },
            else => return error.TypeMismatch,
        };
        return try wrapInCollection(self.allocator, types.Value{ .boolean = result });
    }

    // Helper function to check if a value represents an empty collection in FHIRPath semantics
    fn isEmptyValue(value: types.Value) bool {
        switch (value) {
            .collection => |coll| {
                if (coll.len == 0) return true;
                // Check if collection contains only null_value entries (which represent empty in FHIRPath)
                for (coll) |item| {
                    if (item != .null_value) return false;
                }
                return true; // All items are null_value, treat as empty
            },
            .null_value => return true, // null_value is considered empty
            else => return false,
        }
    }

    fn equalityComparison(self: *Evaluator, left: types.Value, right: types.Value, equal: bool) !types.Value {
        // Memory cleanup handled by top-level caller
        // defer left.deinit(self.allocator);
        // defer right.deinit(self.allocator);
        
        // Handle FHIRPath equality semantics - empty collections return empty collection
        const left_empty = isEmptyValue(left);
        const right_empty = isEmptyValue(right);
        
        // If either operand is empty collection, return empty collection (FHIRPath has no null)
        if (left_empty or right_empty) {
            return types.Value{ .collection = &[_]types.Value{} };
        }
        
        // Both operands have values, perform normal equality comparison
        const are_equal = equalValues(left, right);
        const result = if (equal) are_equal else !are_equal;
        return try wrapInCollection(self.allocator, types.Value{ .boolean = result });
    }

    fn equivalentValues(self: *Evaluator, left: types.Value, right: types.Value) !types.Value {
        // Memory cleanup handled by top-level caller
        // defer left.deinit(self.allocator);
        // defer right.deinit(self.allocator);
        
        // For now, equivalence is the same as equality
        // In full FHIRPath, this would handle more complex equivalence rules
        return try wrapInCollection(self.allocator, types.Value{ .boolean = equalValues(left, right) });
    }

    fn andValues(self: *Evaluator, left: types.Value, right: types.Value) !types.Value {
        // Memory cleanup handled by top-level caller
        // defer left.deinit(self.allocator);
        // defer right.deinit(self.allocator);
        
        return try wrapInCollection(self.allocator, types.Value{ .boolean = toBoolValue(left) and toBoolValue(right) });
    }

    fn orValues(self: *Evaluator, left: types.Value, right: types.Value) !types.Value {
        // Memory cleanup handled by top-level caller
        // defer left.deinit(self.allocator);
        // defer right.deinit(self.allocator);
        
        return try wrapInCollection(self.allocator, types.Value{ .boolean = toBoolValue(left) or toBoolValue(right) });
    }

    fn xorValues(self: *Evaluator, left: types.Value, right: types.Value) !types.Value {
        // Memory cleanup handled by top-level caller
        // defer left.deinit(self.allocator);
        // defer right.deinit(self.allocator);
        
        return try wrapInCollection(self.allocator, types.Value{ .boolean = toBoolValue(left) != toBoolValue(right) });
    }

    fn impliesValues(self: *Evaluator, left: types.Value, right: types.Value) !types.Value {
        // Memory cleanup handled by top-level caller
        // defer left.deinit(self.allocator);
        // defer right.deinit(self.allocator);
        
        return try wrapInCollection(self.allocator, types.Value{ .boolean = !toBoolValue(left) or toBoolValue(right) });
    }
};

// Tests
test "evaluator literals" {
    var context = EvaluationContext.init(std.testing.allocator);
    defer context.deinit();
    var evaluator = Evaluator.init(std.testing.allocator);

    // Test boolean literal
    {
        const location = ast.SourceLocation.init(0, 4, 1, 1);
        var literal = ast.LiteralNode.init(.{ .boolean = true }, location);
        const result = try evaluator.evaluate(&literal.base, &context);
        defer result.deinit(std.testing.allocator);
        try std.testing.expect(result == .collection);
        try std.testing.expectEqual(@as(usize, 1), result.collection.len);
        try std.testing.expectEqual(true, result.collection[0].boolean);
    }

    // Test integer literal
    {
        const location = ast.SourceLocation.init(0, 2, 1, 1);
        var literal = ast.LiteralNode.init(.{ .integer = 42 }, location);
        const result = try evaluator.evaluate(&literal.base, &context);
        defer result.deinit(std.testing.allocator);
        try std.testing.expect(result == .collection);
        try std.testing.expectEqual(@as(usize, 1), result.collection.len);
        try std.testing.expectEqual(@as(i64, 42), result.collection[0].integer);
    }
}

test "evaluator arithmetic" {
    var context = EvaluationContext.init(std.testing.allocator);
    defer context.deinit();
    var evaluator = Evaluator.init(std.testing.allocator);
    const location = ast.SourceLocation.init(0, 5, 1, 1);

    // Create 1 + 2
    var left_literal = ast.LiteralNode.init(.{ .integer = 1 }, location);
    var right_literal = ast.LiteralNode.init(.{ .integer = 2 }, location);
    var binary = ast.BinaryOpNode.init(.plus, &left_literal.base, &right_literal.base, location);

    const result = try evaluator.evaluate(&binary.base, &context);
    defer result.deinit(std.testing.allocator);
    try std.testing.expect(result == .collection);
    try std.testing.expectEqual(@as(usize, 1), result.collection.len);
    try std.testing.expectEqual(@as(i64, 3), result.collection[0].integer);
}
