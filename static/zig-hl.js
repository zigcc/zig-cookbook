const zigLanguageSupport = (hljs) => {
  return {
    name: "Zig",
    aliases: ["zig"],
    keywords: {
      keyword:
      "unreachable continue errdefer suspend return resume cancel break catch async await defer asm try " +
        "threadlocal linksection allowzero stdcallcc volatile comptime noalias nakedcc inline export packed extern align const pub var " +
        "struct union error enum while for switch orelse else and if or usingnamespace test fn",
      type: "comptime_float comptime_int c_longdouble c_ulonglong c_longlong c_voidi8 noreturn c_ushort anyerror promise c_short c_ulong c_uint c_long isize c_int usize void f128 i128 type bool u128 u16 f64 f32 u64 i16 f16 i32 u32 i64 u8 i0 u0",
      literal: "undefined false true null",
    },
    contains: [
      hljs.C_LINE_COMMENT_MODE,
      hljs.QUOTE_STRING_MODE,
      hljs.APOS_STRING_MODE,
      hljs.C_NUMBER_MODE,
      {
        className: "string",
        begin: "@[a-zA-Z_]\\w*",
      },
      {
        className: "meta",
        begin: /@[a-zA-Z_]\w*/,
      },
      {
        className: "symbol",
        begin: /'[a-zA-Z_][a-zA-Z0-9_]*'/,
      },
      {
        className: "literal",
        begin: /\\[xuU][a-fA-F0-9]+/,
      },
      {
        className: "number",
        begin: /\b0x[0-9a-fA-F]+/,
      },
      {
        className: "number",
        begin: /\b0b[01]+/,
      },
      {
        className: "number",
        begin: /\b0o[0-7]+/,
      },
      {
        className: "number",
        begin: /\b[0-9]+\b/,
      },
      hljs.REGEXP_MODE,
    ],
  };
};

document.addEventListener('DOMContentLoaded', (event) => {
  if (typeof hljs !== 'undefined') {
    console.log("register zig support");
    hljs.registerLanguage("zig", zigLanguageSupport);
    hljs.initHighlighting();
  }
});
