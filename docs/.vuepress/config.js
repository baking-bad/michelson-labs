const path = require("path")

module.exports = {
  title: "Michelson Labs",
  description: "Series of Jupyter notebooks for learning the Tezos native contract language",
  theme: "vuepress-theme-book",
  head: [
    ['link', { rel: "icon", type: "image/png", sizes: "16x16", href: "/favicon.png"}],
  ],
  themeConfig: {
    logo: "/logo_small.png",
    searchPlaceholder: "Search...",
    lastUpdated: "Last Updated",
    docsRepo: "baking-bad/michelson-labs",
    docsDir: "docs",
    editLinks: false,
    displayAllHeaders: true,
    nav: [
      { text: "Home", link: "/" },
      { text: "Learn", link: "/learn" },
      { text: "Notebooks ", link: "/introduction"},
      { text: "About", link: "https://baking-bad.org/docs"}
    ],
    sidebar: [
      ['/learn', 'Learn Michelson'],
      {
        title: 'Notebooks',
        collapsable: true,
        sidebarDepth: 1,
        children: [
          ['/introduction', 'Introduction'],
          '/chapters/01',
          '/chapters/02',
          '/chapters/03',
          '/chapters/04',
          '/chapters/05',
          '/chapters/06',
          '/chapters/07',
          '/chapters/08',
          '/chapters/09',
          '/chapters/10',
          '/chapters/11',
          '/chapters/12',
          '/chapters/13',
          '/chapters/14',
          '/chapters/15',
          '/chapters/99'
        ]
      },
      // {
      //   title: 'Examples',
      //   collapsable: true,
      //   sidebarDepth: 1,
      //   children: [
      //     '/examples',
      //     '/advanced/01'
      //   ]
      // }
    ]
  },
  plugins: [
    ['autometa', {
      site: {
        name: 'Michelson Labs',
        twitter: 'TezosBakingBad',
      },
      canonical_base: 'https://michelson.baking-bad.org',
    }],
    ['sitemap', {
      hostname: 'https://michelson.baking-bad.org'
    }],
    ['@vuepress/google-analytics', {
        'ga': 'UA-131043773-1'
    }],
  ],
  extendMarkdown: md => {
    md.use(require('markdown-it-prism'), {init: function(Prism) {
      Prism.languages.Michelson = {
        'punctuation': /[;\{\(\s\)\}]/,
        'comment': {
          pattern: /#.*/,
          greedy: true
        },
        'number': [
          {
            pattern: /(^|\s|\()(?:[+-]?[0-9]+\.?[0-9]*)(?=\s|;|\}|\)|$)/,
            lookbehind: true
          },
          /(?:0x[0-9a-f]+)(?=\s|;|\}|\)|$)/i,
          {
            pattern: /"(?:[^\\]|\\.)*?(?:"|$)/,
            greedy: true
          },
          /(?:Unit|True|False|Pair|Left|Right|Some|None|Elt)(?=\s|;|\)|$)/,
        ],       
        'variable': [
          /(?:IF_SOME|FAIL|ASSERT|ASSERT_NONE|ASSERT_SOME|ASSERT_LEFT|ASSERT_RIGHT|UNPAIR|(?:SET|MAP)_C[AD]+R)(?=\s|;|\}|$)/,
          /(?:DII+P|C[AD]{2,}R|DUU+P|P[PAI]{3,}R|UNP[PAI]{3,}R)(?=\s|;|\}|$)/,
          /(?:(?:CMP|IF|IFCMP|ASSERT_|ASSERT_CMP)(?:EQ|NEQ|LT|GT|LE|GE))(?=\s|;|\}|\{|$)/
        ],
        'attr-name': [
          /(?:%[A-z_0-9%@]*)(?=\s|\)|\}|$)/,
          /(?:@[A-z_0-9%]+)(?=\s|\)|\}|$)/,
          /(?::[A-z_0-9]+)(?=\s|\)|\}|$)/
        ],
        'keyword': [
          /(?:parameter|storage|code)(?=\s|$)/,
          /(?:DUMP|PRINT|DROP_ALL|EXPAND|RUN|PATCH|INCLUDE|DEBUG|BIG_MAP_DIFF|BEGIN|COMMIT|RESET|STORAGE)(?=\s|;|\}|$)/
        ],
        'operator': [
          /(?:INT|ISNAT|CAST|RENAME|DROP|DUP|SWAP|PUSH|SOME|NONE|UNIT|IF_NONE|PAIR|CAR|CDR|LEFT|RIGHT|IF_LEFT|IF_RIGHT|NIL|CONS|IF_CONS|SIZE|EMPTY_SET|EMPTY_MAP|MAP|ITER|MEM|GET|UPDATE|IF|LOOP|LOOP_LEFT|LAMBDA|EXEC|DIP|FAILWITH|CONCAT|SLICE|PACK|UNPACK|ADD|SUB|MUL|EDIV|ABS|NEG|LSL|LSR|OR|AND|XOR|NOT|COMPARE|EQ|NEQ|LT|GT|LE|GE|CHECK_SIGNATURE|BLAKE2B|SHA256|SHA512|HASH_KEY|DIG|DUG|EMPTY_BIG_MAP|APPLY)(?=\s|;|\}|$)/,
          /(?:SELF|CONTRACT|TRANSFER_TOKENS|SET_DELEGATE|CREATE_CONTRACT|IMPLICIT_ACCOUNT|NOW|AMOUNT|BALANCE|STEPS_TO_QUOTA|SOURCE|SENDER|ADDRESS|CHAIN_ID)(?=\s|;|\}|$)/
        ],
        'class-name': [
          /(?:option|list|set|contract|pair|or|lambda|map|big_map)(?=\s|\)|$)/,
          /(?:key|unit|signature|operation|address|int|nat|string|bytes|mutez|bool|key_hash|timestamp|chain_id)(?=\s|\)|\}|;|$)/
        ]
      };
    }})
  },
  extendPageData(pageCtx) {    
    if (!pageCtx.frontmatter.title) {
      pageCtx.frontmatter.title = `${pageCtx.title} | Michelson Labs`;

      if (pageCtx._strippedContent) {
        pageCtx.frontmatter.summary = pageCtx._strippedContent
          .split("\n")
          .find(line => line.length > 20 && !line.startsWith("#"))
      }
    }

    pageCtx.frontmatter.image = "/og.png";
    pageCtx.frontmatter.metaTitle = pageCtx.frontmatter.title;
    pageCtx.frontmatter.description = pageCtx.frontmatter.summary
  }
}
