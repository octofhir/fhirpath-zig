const std = @import("std");
const types = @import("types.zig");
const lexer = @import("lexer.zig");

// Source location for error reporting
pub const SourceLocation = struct {
    start: u32,
    end: u32,
    line: u32,
    column: u32,
    
    pub fn init(start: u32, end: u32, line: u32, column: u32) SourceLocation {
        return SourceLocation{
            .start = start,
            .end = end,
            .line = line,
            .column = column,
        };
    }
};

// Base node interface
pub const Node = struct {
    node_type: NodeType,
    location: SourceLocation,
    
    pub const NodeType = enum {
        literal,
        identifier,
        binary_op,
        unary_op,
        member_access,
        indexer,
        function_call,
        conditional,
        collection,
    };
    
    pub fn init(node_type: NodeType, location: SourceLocation) Node {
        return Node{
            .node_type = node_type,
            .location = location,
        };
    }
    
    pub fn cast(self: *const Node, comptime T: type) ?*const T {
        const expected_type = switch (T) {
            LiteralNode => .literal,
            IdentifierNode => .identifier,
            BinaryOpNode => .binary_op,
            UnaryOpNode => .unary_op,
            MemberAccessNode => .member_access,
            IndexerNode => .indexer,
            FunctionCallNode => .function_call,
            ConditionalNode => .conditional,
            CollectionNode => .collection,
            else => return null,
        };
        
        if (self.node_type != expected_type) return null;
        
        // Calculate the offset to get back to the containing struct
        const base_ptr = @intFromPtr(self);
        const base_offset = @offsetOf(T, "base");
        const struct_ptr = base_ptr - base_offset;
        return @ptrFromInt(struct_ptr);
    }
};

// Literal values (numbers, strings, booleans)
pub const LiteralNode = struct {
    base: Node,
    value: LiteralValue,
    
    pub const LiteralValue = union(enum) {
        boolean: bool,
        integer: i64,
        decimal: f64,
        string: []const u8,
        date: types.Date,
        time: types.Time,
        date_time: types.DateTime,
        quantity: types.Quantity,
        null_value,
    };
    
    pub fn init(value: LiteralValue, location: SourceLocation) LiteralNode {
        return LiteralNode{
            .base = Node.init(.literal, location),
            .value = value,
        };
    }
};

// Identifiers (property names, function names)
pub const IdentifierNode = struct {
    base: Node,
    name: []const u8,
    
    pub fn init(name: []const u8, location: SourceLocation) IdentifierNode {
        return IdentifierNode{
            .base = Node.init(.identifier, location),
            .name = name,
        };
    }
};

// Binary operations (+, -, and, or, etc.)
pub const BinaryOpNode = struct {
    base: Node,
    operator: lexer.TokenType,
    left: *Node,
    right: *Node,
    
    pub fn init(operator: lexer.TokenType, left: *Node, right: *Node, location: SourceLocation) BinaryOpNode {
        return BinaryOpNode{
            .base = Node.init(.binary_op, location),
            .operator = operator,
            .left = left,
            .right = right,
        };
    }
};

// Unary operations (not, -)
pub const UnaryOpNode = struct {
    base: Node,
    operator: lexer.TokenType,
    operand: *Node,
    
    pub fn init(operator: lexer.TokenType, operand: *Node, location: SourceLocation) UnaryOpNode {
        return UnaryOpNode{
            .base = Node.init(.unary_op, location),
            .operator = operator,
            .operand = operand,
        };
    }
};

// Member access (dot notation: obj.property)
pub const MemberAccessNode = struct {
    base: Node,
    object: *Node,
    property: []const u8,
    
    pub fn init(object: *Node, property: []const u8, location: SourceLocation) MemberAccessNode {
        return MemberAccessNode{
            .base = Node.init(.member_access, location),
            .object = object,
            .property = property,
        };
    }
};

// Array/collection indexing (obj[index])
pub const IndexerNode = struct {
    base: Node,
    object: *Node,
    index: *Node,
    
    pub fn init(object: *Node, index: *Node, location: SourceLocation) IndexerNode {
        return IndexerNode{
            .base = Node.init(.indexer, location),
            .object = object,
            .index = index,
        };
    }
};

// Function calls
pub const FunctionCallNode = struct {
    base: Node,
    function_name: []const u8,
    arguments: []*Node,
    
    pub fn init(function_name: []const u8, arguments: []*Node, location: SourceLocation) FunctionCallNode {
        return FunctionCallNode{
            .base = Node.init(.function_call, location),
            .function_name = function_name,
            .arguments = arguments,
        };
    }
};

// Conditional expressions (if-then-else, ternary)
pub const ConditionalNode = struct {
    base: Node,
    condition: *Node,
    then_expr: *Node,
    else_expr: ?*Node,
    
    pub fn init(condition: *Node, then_expr: *Node, else_expr: ?*Node, location: SourceLocation) ConditionalNode {
        return ConditionalNode{
            .base = Node.init(.conditional, location),
            .condition = condition,
            .then_expr = then_expr,
            .else_expr = else_expr,
        };
    }
};

pub const CollectionNode = struct {
    base: Node,
    elements: []*Node,
    
    pub fn init(elements: []*Node, location: SourceLocation) CollectionNode {
        return CollectionNode{
            .base = Node.init(.collection, location),
            .elements = elements,
        };
    }
};

// Visitor pattern for AST traversal
pub const Visitor = struct {
    const Self = @This();
    
    visitLiteralFn: ?*const fn(*Self, *const LiteralNode) anyerror!void = null,
    visitIdentifierFn: ?*const fn(*Self, *const IdentifierNode) anyerror!void = null,
    visitBinaryOpFn: ?*const fn(*Self, *const BinaryOpNode) anyerror!void = null,
    visitUnaryOpFn: ?*const fn(*Self, *const UnaryOpNode) anyerror!void = null,
    visitMemberAccessFn: ?*const fn(*Self, *const MemberAccessNode) anyerror!void = null,
    visitIndexerFn: ?*const fn(*Self, *const IndexerNode) anyerror!void = null,
    visitFunctionCallFn: ?*const fn(*Self, *const FunctionCallNode) anyerror!void = null,
    visitConditionalFn: ?*const fn(*Self, *const ConditionalNode) anyerror!void = null,
    
    pub fn visit(self: *Self, node: *const Node) !void {
        switch (node.node_type) {
            .literal => {
                if (self.visitLiteralFn) |func| {
                    const literal = node.cast(LiteralNode) orelse return error.InvalidCast;
                    try func(self, literal);
                }
            },
            .identifier => {
                if (self.visitIdentifierFn) |func| {
                    const identifier = node.cast(IdentifierNode) orelse return error.InvalidCast;
                    try func(self, identifier);
                }
            },
            .binary_op => {
                if (self.visitBinaryOpFn) |func| {
                    const binary_op = node.cast(BinaryOpNode) orelse return error.InvalidCast;
                    try func(self, binary_op);
                }
            },
            .unary_op => {
                if (self.visitUnaryOpFn) |func| {
                    const unary_op = node.cast(UnaryOpNode) orelse return error.InvalidCast;
                    try func(self, unary_op);
                }
            },
            .member_access => {
                if (self.visitMemberAccessFn) |func| {
                    const member_access = node.cast(MemberAccessNode) orelse return error.InvalidCast;
                    try func(self, member_access);
                }
            },
            .indexer => {
                if (self.visitIndexerFn) |func| {
                    const indexer = node.cast(IndexerNode) orelse return error.InvalidCast;
                    try func(self, indexer);
                }
            },
            .function_call => {
                if (self.visitFunctionCallFn) |func| {
                    const function_call = node.cast(FunctionCallNode) orelse return error.InvalidCast;
                    try func(self, function_call);
                }
            },
            .conditional => {
                if (self.visitConditionalFn) |func| {
                    const conditional = node.cast(ConditionalNode) orelse return error.InvalidCast;
                    try func(self, conditional);
                }
            },
        }
    }
};

// Tests
test "ast node creation" {
    const location = SourceLocation.init(0, 4, 1, 1);
    
    // Literal node
    const literal = LiteralNode.init(.{ .boolean = true }, location);
    try std.testing.expectEqual(Node.NodeType.literal, literal.base.node_type);
    try std.testing.expectEqual(true, literal.value.boolean);
    
    // Identifier node
    const identifier = IdentifierNode.init("name", location);
    try std.testing.expectEqual(Node.NodeType.identifier, identifier.base.node_type);
    try std.testing.expectEqualStrings("name", identifier.name);
}

test "ast node casting" {
    const location = SourceLocation.init(0, 4, 1, 1);
    var literal = LiteralNode.init(.{ .integer = 42 }, location);
    const node: *const Node = &literal.base;
    
    // Debug: check original literal
    try std.testing.expectEqual(@as(i64, 42), literal.value.integer);
    
    // Successful cast
    const cast_literal = node.cast(LiteralNode);
    try std.testing.expect(cast_literal != null);
    
    // Debug: check what we got
    switch (cast_literal.?.value) {
        .integer => |val| try std.testing.expectEqual(@as(i64, 42), val),
        else => try std.testing.expect(false), // Should not happen
    }
    
    // Failed cast
    const cast_identifier = node.cast(IdentifierNode);
    try std.testing.expect(cast_identifier == null);
}

/// Free an AST node and all its children recursively
pub fn freeNode(allocator: std.mem.Allocator, node: *Node) void {
    switch (node.node_type) {
        .literal => {
            const literal = node.cast(LiteralNode).?;
            // Note: string literals are usually slices of the original expression,
            // so we don't free them here to avoid double-free
            allocator.destroy(literal);
        },
        .identifier => {
            const identifier = node.cast(IdentifierNode).?;
            // Note: identifier names are usually slices of the original expression
            // allocator.free(identifier.name); // Don't free to avoid double-free
            allocator.destroy(identifier);
        },
        .binary_op => {
            const binary = node.cast(BinaryOpNode).?;
            freeNode(allocator, binary.left);
            freeNode(allocator, binary.right);
            allocator.destroy(binary);
        },
        .unary_op => {
            const unary = node.cast(UnaryOpNode).?;
            freeNode(allocator, unary.operand);
            allocator.destroy(unary);
        },
        .function_call => {
            const func = node.cast(FunctionCallNode).?;
            // Note: function names are usually slices of the original expression
            // allocator.free(func.function_name); // Don't free to avoid double-free
            for (func.arguments) |arg| {
                freeNode(allocator, arg);
            }
            allocator.free(func.arguments);
            allocator.destroy(func);
        },
        .member_access => {
            const member = node.cast(MemberAccessNode).?;
            freeNode(allocator, member.object);
            // Note: property names are usually slices of the original expression
            // allocator.free(member.property); // Don't free to avoid double-free
            allocator.destroy(member);
        },
        .indexer => {
            const indexer = node.cast(IndexerNode).?;
            freeNode(allocator, indexer.object);
            freeNode(allocator, indexer.index);
            allocator.destroy(indexer);
        },
        .conditional => {
            // TODO: Add ConditionalNode support when implemented
            @panic("Conditional nodes not yet implemented");
        },
        .collection => {
            const collection = node.cast(CollectionNode).?;
            for (collection.elements) |element| {
                freeNode(allocator, element);
            }
            allocator.free(collection.elements);
            allocator.destroy(collection);
        },
    }
}