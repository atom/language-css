describe 'CSS grammar', ->
  grammar = null

  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('language-css')

    runs ->
      grammar = atom.grammars.grammarForScopeName('source.css')

  it 'parses the grammar', ->
    expect(grammar).toBeTruthy()
    expect(grammar.scopeName).toBe 'source.css'

  describe 'selectors', ->
    it 'tokenizes type selectors', ->
      {tokens} = grammar.tokenizeLine 'p {}'
      expect(tokens[0]).toEqual value: 'p', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.css']

    it 'tokenizes the universal selector', ->
      {tokens} = grammar.tokenizeLine '*'
      expect(tokens[0]).toEqual value: '*', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.wildcard.css']

    # Needs more complex examples
    it 'tokenizes complex selectors', ->
      {tokens} = grammar.tokenizeLine '[disabled], [disabled] + p'
      expect(tokens[0]).toEqual value: '[', scopes: ["source.css", "meta.selector.css", "meta.attribute-selector.css", "punctuation.definition.entity.css"]
      expect(tokens[1]).toEqual value: 'disabled', scopes: ["source.css", "meta.selector.css", "meta.attribute-selector.css", "entity.other.attribute-name.css"]
      expect(tokens[2]).toEqual value: ']', scopes: ["source.css", "meta.selector.css", "meta.attribute-selector.css", "punctuation.definition.entity.css"]
      expect(tokens[3]).toEqual value: ', ', scopes: ["source.css", "meta.selector.css"]
      expect(tokens[4]).toEqual value: '[', scopes: ["source.css", "meta.selector.css", "meta.attribute-selector.css", "punctuation.definition.entity.css"]
      expect(tokens[5]).toEqual value: 'disabled', scopes: ["source.css", "meta.selector.css", "meta.attribute-selector.css", "entity.other.attribute-name.css"]
      expect(tokens[6]).toEqual value: ']', scopes: ["source.css", "meta.selector.css", "meta.attribute-selector.css", "punctuation.definition.entity.css"]
      expect(tokens[7]).toEqual value: ' + ', scopes: ["source.css", "meta.selector.css"]
      expect(tokens[8]).toEqual value: 'p', scopes: ["source.css", "meta.selector.css", "entity.name.tag.css"]

    describe 'custom elements (as type selectors)', ->
      it 'only tokenizes identifiers beginning with [a-z]', ->
        {tokens} = grammar.tokenizeLine 'pearl-1941 1941-pearl -pearl-1941'
        expect(tokens[0]).toEqual value: 'pearl-1941', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
        expect(tokens[1]).toEqual value: ' 1941-pearl -pearl-1941', scopes: ['source.css', 'meta.selector.css']

      it 'tokenizes custom elements containing non-ASCII letters', ->
        {tokens} = grammar.tokenizeLine 'pokémon-ピカチュウ'
        expect(tokens[0]).toEqual value: 'pokémon-ピカチュウ', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']

      it 'does not tokenize identifiers containing [A-Z]', ->
        {tokens} = grammar.tokenizeLine 'Basecamp-schedule basecamp-Schedule'
        expect(tokens[0]).toEqual value: 'Basecamp-schedule basecamp-Schedule', scopes: ['source.css', 'meta.selector.css']

      it 'does not tokenize identifiers containing no hyphens', ->
        {tokens} = grammar.tokenizeLine 'halo_night'
        expect(tokens[0]).toEqual value: 'halo_night', scopes: ['source.css', 'meta.selector.css']

    describe 'attribute selectors', ->
      it 'tokenizes attribute selectors without values', ->
        {tokens} = grammar.tokenizeLine '[title]'
        expect(tokens[0]).toEqual value: '[', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: 'title', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'entity.other.attribute-name.css']
        expect(tokens[2]).toEqual value: ']', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.definition.entity.css']

      it 'tokenizes attribute selectors with identifier values', ->
        {tokens} = grammar.tokenizeLine '[hreflang|=fr]'
        expect(tokens[0]).toEqual value: '[', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: 'hreflang', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'entity.other.attribute-name.css']
        expect(tokens[2]).toEqual value: '|=', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'keyword.operator.pattern.css']
        expect(tokens[3]).toEqual value: 'fr', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'string.unquoted.attribute-value.css']
        expect(tokens[4]).toEqual value: ']', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.definition.entity.css']

      it 'tokenizes attribute selectors with string values', ->
        {tokens} = grammar.tokenizeLine '[href^="http://www.w3.org/"]'
        expect(tokens[0]).toEqual value: '[', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: 'href', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'entity.other.attribute-name.css']
        expect(tokens[2]).toEqual value: '^=', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'keyword.operator.pattern.css']
        expect(tokens[3]).toEqual value: '"', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'string.quoted.attribute-value.css', 'punctuation.definition.string.begin.css']
        expect(tokens[4]).toEqual value: 'http://www.w3.org/', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'string.quoted.attribute-value.css']
        expect(tokens[5]).toEqual value: '"', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'string.quoted.attribute-value.css', 'punctuation.definition.string.end.css']
        expect(tokens[6]).toEqual value: ']', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.definition.entity.css']

      it 'tokenizes CSS qualified attribute names with wildcard prefix', ->
        {tokens} = grammar.tokenizeLine '[*|title]'
        expect(tokens[0]).toEqual value: '[', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: '*', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'entity.other.namespace-prefix.css']
        expect(tokens[2]).toEqual value: '|', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.separator.css']
        expect(tokens[3]).toEqual value: 'title', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'entity.other.attribute-name.css']
        expect(tokens[4]).toEqual value: ']', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.definition.entity.css']

      it 'tokenizes CSS qualified attribute names with namespace prefix', ->
        {tokens} = grammar.tokenizeLine '[marvel|origin=radiation]'
        expect(tokens[0]).toEqual value: '[', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: 'marvel', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'entity.other.namespace-prefix.css']
        expect(tokens[2]).toEqual value: '|', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.separator.css']
        expect(tokens[3]).toEqual value: 'origin', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'entity.other.attribute-name.css']
        expect(tokens[4]).toEqual value: '=', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'keyword.operator.pattern.css']
        expect(tokens[5]).toEqual value: 'radiation', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'string.unquoted.attribute-value.css']
        expect(tokens[6]).toEqual value: ']', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.definition.entity.css']

      it 'tokenizes CSS qualified attribute names without namespace prefix', ->
        {tokens} = grammar.tokenizeLine '[|data-hp="75"]'
        expect(tokens[0]).toEqual value: '[', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: '|', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.separator.css']
        expect(tokens[2]).toEqual value: 'data-hp', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'entity.other.attribute-name.css']
        expect(tokens[3]).toEqual value: '=', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'keyword.operator.pattern.css']
        expect(tokens[4]).toEqual value: '"', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'string.quoted.attribute-value.css', 'punctuation.definition.string.begin.css']
        expect(tokens[5]).toEqual value: '75', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'string.quoted.attribute-value.css']
        expect(tokens[6]).toEqual value: '"', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'string.quoted.attribute-value.css', 'punctuation.definition.string.end.css']
        expect(tokens[7]).toEqual value: ']', scopes: ['source.css', 'meta.selector.css', 'meta.attribute-selector.css', 'punctuation.definition.entity.css']

    describe 'class selectors', ->
      it 'tokenizes class selectors containing non-ASCII letters', ->
        {tokens} = grammar.tokenizeLine '.étendard'
        expect(tokens[0]).toEqual value: '.', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: 'étendard', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.class.css']

        {tokens} = grammar.tokenizeLine '.スポンサー'
        expect(tokens[0]).toEqual value: '.', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: 'スポンサー', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.class.css']

      it 'tokenizes a class selector consisting of two hypens', ->
        {tokens} = grammar.tokenizeLine '.--'
        expect(tokens[0]).toEqual value: '.', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: '--', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.class.css']

      it 'tokenizes class selectors consisting of one (valid) character', ->
        {tokens} = grammar.tokenizeLine '._'
        expect(tokens[0]).toEqual value: '.', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: '_', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.class.css']

      it 'does not tokenize tokens containing ASCII punctuation or symbols other than "-" and "_"', ->
        {tokens} = grammar.tokenizeLine '.B&W'
        expect(tokens[0]).toEqual value: '.B&W', scopes: ['source.css', 'meta.selector.css']

      it 'does not tokenize tokens beginning with [0-9]', ->
        {tokens} = grammar.tokenizeLine '.666'
        expect(tokens[0]).toEqual value: '.666', scopes: ['source.css', 'meta.selector.css']

      it 'does not tokenize tokens beginning with "-" followed by [0-9]', ->
        {tokens} = grammar.tokenizeLine '.-911-'
        expect(tokens[0]).toEqual value: '.-911-', scopes: ['source.css', 'meta.selector.css']

      it 'does not tokenize a token consisting of one hyphen', ->
        {tokens} = grammar.tokenizeLine '.-'
        expect(tokens[0]).toEqual value: '.-', scopes: ['source.css', 'meta.selector.css']

    describe 'id selectors', ->
      it 'tokenizes id selectors consisting of ASCII letters', ->
        {tokens} = grammar.tokenizeLine '#unicorn'
        expect(tokens[0]).toEqual value: '#', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.id.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: 'unicorn', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.id.css']

      it 'tokenizes id selectors containing non-ASCII letters', ->
        {tokens} = grammar.tokenizeLine '#洪荒之力'
        expect(tokens[0]).toEqual value: '#', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.id.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: '洪荒之力', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.id.css']

      it 'tokenizes id selectors containing [0-9], "-", or "_"', ->
        {tokens} = grammar.tokenizeLine '#_zer0-day'
        expect(tokens[0]).toEqual value: '#', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.id.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: '_zer0-day', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.id.css']

      it 'tokenizes id selectors beginning with two hyphens', ->
        {tokens} = grammar.tokenizeLine '#--d3bug--'
        expect(tokens[0]).toEqual value: '#', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.id.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: '--d3bug--', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.id.css']

      it 'does not tokenize hash tokens containing ASCII punctuation or symbols other than "-" and "_"', ->
        {tokens} = grammar.tokenizeLine '#sort!'
        expect(tokens[0]).toEqual value: '#sort!', scopes: ['source.css', 'meta.selector.css']

      it 'does not tokenize hash tokens beginning with [0-9]', ->
        {tokens} = grammar.tokenizeLine '#666'
        expect(tokens[0]).toEqual value: '#666', scopes: ['source.css', 'meta.selector.css']

      it 'does not tokenize hash tokens beginning with "-" followed by [0-9]', ->
        {tokens} = grammar.tokenizeLine '#-911-'
        expect(tokens[0]).toEqual value: '#-911-', scopes: ['source.css', 'meta.selector.css']

      it 'does not tokenize a hash token consisting of one hyphen', ->
        {tokens} = grammar.tokenizeLine '#-'
        expect(tokens[0]).toEqual value: '#-', scopes: ['source.css', 'meta.selector.css']

    describe 'at-rules', ->
      describe '@charset', ->
        it 'tokenises @charset rules at the start of a file', ->
          lines = grammar.tokenizeLines "@charset 'US-ASCII';"
          expect(lines[0][0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.charset.css', 'keyword.control.at-rule.charset.css', 'punctuation.definition.keyword.css']
          expect(lines[0][1]).toEqual value: 'charset', scopes: ['source.css', 'meta.at-rule.charset.css', 'keyword.control.at-rule.charset.css']
          expect(lines[0][2]).toEqual value: ' ', scopes: ['source.css', 'meta.at-rule.charset.css']
          expect(lines[0][3]).toEqual value: "'", scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.single.css', 'punctuation.definition.string.begin.css']
          expect(lines[0][4]).toEqual value: 'US-ASCII', scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.single.css']
          expect(lines[0][5]).toEqual value: "'", scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.single.css', 'punctuation.definition.string.end.css']
          expect(lines[0][6]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.charset.css', 'punctuation.terminator.at-rule.css']

          lines = grammar.tokenizeLines('/* Not the first line */\n@charset "UTF-8";')
          expect(lines[0][0]).toEqual value: '/*', scopes: ['source.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(lines[0][1]).toEqual value: ' Not the first line ', scopes: ['source.css', 'comment.block.css']
          expect(lines[0][2]).toEqual value: '*/', scopes: ['source.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(lines[1][0]).toEqual value: '@', scopes: ['source.css']
          expect(lines[1][1]).toEqual value: 'charset "UTF-8";', scopes: ['source.css', 'meta.selector.css']

        it 'highlights invalid @charset statements', ->
          lines = grammar.tokenizeLines " @charset 'US-ASCII';"
          expect(lines[0][0]).toEqual value: ' ', scopes: ['source.css', 'meta.at-rule.charset.css', 'invalid.illegal.leading-whitespace.charset.css']
          expect(lines[0][1]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.charset.css', 'keyword.control.at-rule.charset.css', 'punctuation.definition.keyword.css']
          expect(lines[0][2]).toEqual value: 'charset', scopes: ['source.css', 'meta.at-rule.charset.css', 'keyword.control.at-rule.charset.css']
          expect(lines[0][4]).toEqual value: "'", scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.single.css', 'punctuation.definition.string.begin.css']
          expect(lines[0][5]).toEqual value: 'US-ASCII', scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.single.css']
          expect(lines[0][6]).toEqual value: "'", scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.single.css', 'punctuation.definition.string.end.css']
          expect(lines[0][7]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.charset.css', 'punctuation.terminator.at-rule.css']

          lines = grammar.tokenizeLines '@charset  "iso-8859-15";'
          expect(lines[0][0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.charset.css', 'keyword.control.at-rule.charset.css', 'punctuation.definition.keyword.css']
          expect(lines[0][1]).toEqual value: 'charset', scopes: ['source.css', 'meta.at-rule.charset.css', 'keyword.control.at-rule.charset.css']
          expect(lines[0][2]).toEqual value: '  ', scopes: ['source.css', 'meta.at-rule.charset.css', 'invalid.illegal.whitespace.charset.css']
          expect(lines[0][3]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(lines[0][4]).toEqual value: 'iso-8859-15', scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.double.css']
          expect(lines[0][5]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(lines[0][6]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.charset.css', 'punctuation.terminator.at-rule.css']

          lines = grammar.tokenizeLines '@charset"US-ASCII";'
          expect(lines[0][0]).toEqual value: '@charset"US-ASCII"', scopes: ['source.css', 'meta.at-rule.charset.css', 'invalid.illegal.no-whitespace.charset.css']
          expect(lines[0][1]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.charset.css', 'punctuation.terminator.at-rule.css']

          lines = grammar.tokenizeLines '@charset "UTF-8" ;'
          expect(lines[0][0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.charset.css', 'keyword.control.at-rule.charset.css', 'punctuation.definition.keyword.css']
          expect(lines[0][1]).toEqual value: 'charset', scopes: ['source.css', 'meta.at-rule.charset.css', 'keyword.control.at-rule.charset.css']
          expect(lines[0][2]).toEqual value: ' ', scopes: ['source.css', 'meta.at-rule.charset.css']
          expect(lines[0][3]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(lines[0][4]).toEqual value: 'UTF-8', scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.double.css']
          expect(lines[0][5]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(lines[0][6]).toEqual value: ' ', scopes: ['source.css', 'meta.at-rule.charset.css', 'invalid.illegal.unexpected-characters.charset.css']
          expect(lines[0][7]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.charset.css', 'punctuation.terminator.at-rule.css']

          lines = grammar.tokenizeLines '@charset "WTF-8" /* Nope */ ;'
          expect(lines[0][0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.charset.css', 'keyword.control.at-rule.charset.css', 'punctuation.definition.keyword.css']
          expect(lines[0][1]).toEqual value: 'charset', scopes: ['source.css', 'meta.at-rule.charset.css', 'keyword.control.at-rule.charset.css']
          expect(lines[0][2]).toEqual value: ' ', scopes: ['source.css', 'meta.at-rule.charset.css']
          expect(lines[0][3]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(lines[0][4]).toEqual value: 'WTF-8', scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.double.css']
          expect(lines[0][5]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(lines[0][6]).toEqual value: ' /* Nope */ ', scopes: ['source.css', 'meta.at-rule.charset.css', 'invalid.illegal.unexpected-characters.charset.css']
          expect(lines[0][7]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.charset.css', 'punctuation.terminator.at-rule.css']

          lines = grammar.tokenizeLines '@charset "UTF-8'
          expect(lines[0][0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.charset.css', 'keyword.control.at-rule.charset.css', 'punctuation.definition.keyword.css']
          expect(lines[0][1]).toEqual value: 'charset', scopes: ['source.css', 'meta.at-rule.charset.css', 'keyword.control.at-rule.charset.css']
          expect(lines[0][2]).toEqual value: ' ', scopes: ['source.css', 'meta.at-rule.charset.css']
          expect(lines[0][3]).toEqual value: '"UTF-8', scopes: ['source.css', 'meta.at-rule.charset.css', 'invalid.illegal.unclosed-string.charset.css']

          lines = grammar.tokenizeLines "@CHARSET 'US-ASCII';"
          expect(lines[0][0]).toEqual value: '@CHARSET', scopes: ['source.css', 'meta.at-rule.charset.css', 'invalid.illegal.not-lowercase.charset.css']
          expect(lines[0][1]).toEqual value: ' ', scopes: ['source.css', 'meta.at-rule.charset.css']
          expect(lines[0][2]).toEqual value: "'", scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.single.css', 'punctuation.definition.string.begin.css']
          expect(lines[0][3]).toEqual value: 'US-ASCII', scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.single.css']
          expect(lines[0][4]).toEqual value: "'", scopes: ['source.css', 'meta.at-rule.charset.css', 'string.quoted.single.css', 'punctuation.definition.string.end.css']
          expect(lines[0][5]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.charset.css', 'punctuation.terminator.at-rule.css']

      describe '@import', ->
        it 'tokenises @import statements', ->
          {tokens} = grammar.tokenizeLine('@import url("file.css");')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'import', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css']
          expect(tokens[3]).toEqual value: 'url', scopes: ['source.css', 'meta.at-rule.import.css', 'support.function.url.css']
          expect(tokens[4]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.section.function.css']
          expect(tokens[5]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[6]).toEqual value: 'file.css', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css']
          expect(tokens[7]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[8]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.section.function.css']
          expect(tokens[9]).toEqual value: ';', scopes: ['source.css']

          {tokens} = grammar.tokenizeLine('@import "file.css";')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'import', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css']
          expect(tokens[3]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[4]).toEqual value: 'file.css', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css']
          expect(tokens[5]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[6]).toEqual value: ';', scopes: ['source.css']

          {tokens} = grammar.tokenizeLine("@import 'file.css';")
          expect(tokens[3]).toEqual value: "'", scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.single.css', 'punctuation.definition.string.begin.css']
          expect(tokens[4]).toEqual value: 'file.css', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.single.css']
          expect(tokens[5]).toEqual value: "'", scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.single.css', 'punctuation.definition.string.end.css']

        it "doesn't let injected comments impact parameter matching", ->
          {tokens} = grammar.tokenizeLine('@import /* url("name"); */ "1.css";')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'import', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css']
          expect(tokens[3]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[4]).toEqual value: ' url("name"); ', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css']
          expect(tokens[5]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[7]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[8]).toEqual value: '1.css', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css']
          expect(tokens[9]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[10]).toEqual value: ';', scopes: ['source.css']

          {tokens} = grammar.tokenizeLine('@import/* Comment */"2.css";')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'import', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css']
          expect(tokens[2]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[3]).toEqual value: ' Comment ', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css']
          expect(tokens[4]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[5]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[6]).toEqual value: '2.css', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css']
          expect(tokens[7]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[8]).toEqual value: ';', scopes: ['source.css']

        it 'correctly handles word boundaries', ->
          {tokens} = grammar.tokenizeLine('@import"file.css";')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'import', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css']
          expect(tokens[2]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[3]).toEqual value: 'file.css', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css']
          expect(tokens[4]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[5]).toEqual value: ';', scopes: ['source.css']

          {tokens} = grammar.tokenizeLine('@import-file.css;')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css']
          expect(tokens[1]).toEqual value: 'import-file', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']

        it 'matches a URL that starts on the next line', ->
          lines = grammar.tokenizeLines '@import\nurl("file.css");'
          expect(lines[0][0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css', 'punctuation.definition.keyword.css']
          expect(lines[0][1]).toEqual value: 'import', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css']
          expect(lines[0][2]).toEqual value: '', scopes: ['source.css', 'meta.at-rule.import.css']
          expect(lines[1][0]).toEqual value: 'url', scopes: ['source.css', 'meta.at-rule.import.css', 'support.function.url.css']
          expect(lines[1][1]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.section.function.css']
          expect(lines[1][2]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(lines[1][3]).toEqual value: 'file.css', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css']
          expect(lines[1][4]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(lines[1][5]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.section.function.css']
          expect(lines[1][6]).toEqual value: ';', scopes: ['source.css']

        it 'matches comments inside query lists', ->
          {tokens} = grammar.tokenizeLine('@import url("1.css") print /* url(";"); */ all;')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'import', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css']
          expect(tokens[3]).toEqual value: 'url', scopes: ['source.css', 'meta.at-rule.import.css', 'support.function.url.css']
          expect(tokens[4]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.section.function.css']
          expect(tokens[5]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[6]).toEqual value: '1.css', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css']
          expect(tokens[7]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[8]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.section.function.css']
          expect(tokens[10]).toEqual value: 'print', scopes: ['source.css', 'meta.at-rule.import.css', 'support.constant.media.css']
          expect(tokens[12]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[13]).toEqual value: ' url(";"); ', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css']
          expect(tokens[14]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[16]).toEqual value: 'all', scopes: ['source.css', 'meta.at-rule.import.css', 'support.constant.media.css']
          expect(tokens[17]).toEqual value: ';', scopes: ['source.css']

        it 'highlights deprecated media types', ->
          {tokens} = grammar.tokenizeLine('@import "astral.css" projection;')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'import', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css']
          expect(tokens[3]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[4]).toEqual value: 'astral.css', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css']
          expect(tokens[5]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[7]).toEqual value: 'projection', scopes: ['source.css', 'meta.at-rule.import.css', 'invalid.deprecated.constant.media.css']
          expect(tokens[8]).toEqual value: ';', scopes: ['source.css']

        it 'highlights media features in query lists', ->
          {tokens} = grammar.tokenizeLine('@import url(\'landscape.css\') screen and (orientation:landscape);')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'import', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css']
          expect(tokens[3]).toEqual value: 'url', scopes: ['source.css', 'meta.at-rule.import.css', 'support.function.url.css']
          expect(tokens[4]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.section.function.css']
          expect(tokens[5]).toEqual value: '\'', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.single.css', 'punctuation.definition.string.begin.css']
          expect(tokens[6]).toEqual value: 'landscape.css', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.single.css']
          expect(tokens[7]).toEqual value: '\'', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.single.css', 'punctuation.definition.string.end.css']
          expect(tokens[8]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.section.function.css']
          expect(tokens[10]).toEqual value: 'screen', scopes: ['source.css', 'meta.at-rule.import.css', 'support.constant.media.css']
          expect(tokens[12]).toEqual value: 'and', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.operator.logical.and.media.css']
          expect(tokens[14]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.definition.parameters.begin.bracket.round.css']
          expect(tokens[15]).toEqual value: 'orientation', scopes: ['source.css', 'meta.at-rule.import.css', 'support.type.property-name.media.css']
          expect(tokens[16]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.separator.key-value.css']
          expect(tokens[17]).toEqual value: 'landscape', scopes: ['source.css', 'meta.at-rule.import.css', 'support.constant.property-value.css']
          expect(tokens[18]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.definition.parameters.end.bracket.round.css']
          expect(tokens[19]).toEqual value: ';', scopes: ['source.css']

      describe '@media', ->
        it 'tokenises @media keywords correctly', ->
          {tokens} = grammar.tokenizeLine('@media(max-width: 37.5em){ }')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'media', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']
          expect(tokens[2]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.begin.bracket.round.css']
          expect(tokens[3]).toEqual value: 'max-width', scopes: ['source.css', 'meta.at-rule.media.css', 'support.type.property-name.media.css']
          expect(tokens[4]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
          expect(tokens[6]).toEqual value: '37.5', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css']
          expect(tokens[7]).toEqual value: 'em', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css', 'keyword.other.unit.css']
          expect(tokens[8]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.end.bracket.round.css']
          expect(tokens[9]).toEqual value: '{', scopes: ['source.css', 'punctuation.section.property-list.begin.css']
          expect(tokens[11]).toEqual value: '}', scopes: ['source.css', 'punctuation.section.property-list.end.css']

          {tokens} = grammar.tokenizeLine('@media not print and (max-width: 37.5em){ }')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'media', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']
          expect(tokens[3]).toEqual value: 'not', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.operator.logical.not.media.css']
          expect(tokens[5]).toEqual value: 'print', scopes: ['source.css', 'meta.at-rule.media.css', 'support.constant.media.css']
          expect(tokens[7]).toEqual value: 'and', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.operator.logical.and.media.css']
          expect(tokens[9]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.begin.bracket.round.css']
          expect(tokens[10]).toEqual value: 'max-width', scopes: ['source.css', 'meta.at-rule.media.css', 'support.type.property-name.media.css']
          expect(tokens[11]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
          expect(tokens[13]).toEqual value: '37.5', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css']
          expect(tokens[14]).toEqual value: 'em', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css', 'keyword.other.unit.css']
          expect(tokens[15]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.end.bracket.round.css']
          expect(tokens[16]).toEqual value: '{', scopes: ['source.css', 'punctuation.section.property-list.begin.css']
          expect(tokens[18]).toEqual value: '}', scopes: ['source.css', 'punctuation.section.property-list.end.css']

        it 'highlights deprecated media types', ->
          {tokens} = grammar.tokenizeLine('@media (max-device-width: 2px){ }')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'media', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']
          expect(tokens[3]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.begin.bracket.round.css']
          expect(tokens[4]).toEqual value: 'max-device-width', scopes: ['source.css', 'meta.at-rule.media.css', 'invalid.deprecated.media.css']
          expect(tokens[5]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
          expect(tokens[7]).toEqual value: '2', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css']
          expect(tokens[8]).toEqual value: 'px', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css', 'keyword.other.unit.css']
          expect(tokens[9]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.end.bracket.round.css']
          expect(tokens[10]).toEqual value: '{', scopes: ['source.css', 'punctuation.section.property-list.begin.css']
          expect(tokens[12]).toEqual value: '}', scopes: ['source.css', 'punctuation.section.property-list.end.css']

        it 'highlights vendored media features', ->
          {tokens} = grammar.tokenizeLine('@media (-webkit-foo: bar){ b{ } }')
          expect(tokens[3]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.begin.bracket.round.css']
          expect(tokens[4]).toEqual value: '-webkit-foo', scopes: ['source.css', 'meta.at-rule.media.css', 'support.type.vendored.property-name.media.css']
          expect(tokens[5]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
          expect(tokens[6]).toEqual value: ' bar', scopes: ['source.css', 'meta.at-rule.media.css']
          expect(tokens[7]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.end.bracket.round.css']
          expect(tokens[8]).toEqual value: '{', scopes: ['source.css', 'punctuation.section.property-list.begin.css']

          {tokens} = grammar.tokenizeLine('@media screen and (-ms-high-contrast:black-on-white){ }')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'media', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']
          expect(tokens[3]).toEqual value: 'screen', scopes: ['source.css', 'meta.at-rule.media.css', 'support.constant.media.css']
          expect(tokens[5]).toEqual value: 'and', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.operator.logical.and.media.css']
          expect(tokens[7]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.begin.bracket.round.css']
          expect(tokens[8]).toEqual value: '-ms-high-contrast', scopes: ['source.css', 'meta.at-rule.media.css', 'support.type.vendored.property-name.media.css']
          expect(tokens[9]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
          expect(tokens[10]).toEqual value: 'black-on-white', scopes: ['source.css', 'meta.at-rule.media.css']
          expect(tokens[11]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.end.bracket.round.css']
          expect(tokens[12]).toEqual value: '{', scopes: ['source.css', 'punctuation.section.property-list.begin.css']
          expect(tokens[14]).toEqual value: '}', scopes: ['source.css', 'punctuation.section.property-list.end.css']

        it 'tokenises comments between media types', ->
          {tokens} = grammar.tokenizeLine('@media/* */only/* */screen/* */and (min-width:1100px){}')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'media', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']
          expect(tokens[2]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[4]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[5]).toEqual value: 'only', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.operator.logical.only.media.css']
          expect(tokens[6]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[8]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[9]).toEqual value: 'screen', scopes: ['source.css', 'meta.at-rule.media.css', 'support.constant.media.css']
          expect(tokens[10]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[12]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[13]).toEqual value: 'and', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.operator.logical.and.media.css']
          expect(tokens[15]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.begin.bracket.round.css']
          expect(tokens[16]).toEqual value: 'min-width', scopes: ['source.css', 'meta.at-rule.media.css', 'support.type.property-name.media.css']
          expect(tokens[17]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
          expect(tokens[18]).toEqual value: '1100', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css']
          expect(tokens[19]).toEqual value: 'px', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css', 'keyword.other.unit.css']
          expect(tokens[20]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.end.bracket.round.css']
          expect(tokens[21]).toEqual value: '{', scopes: ['source.css', 'punctuation.section.property-list.begin.css']
          expect(tokens[22]).toEqual value: '}', scopes: ['source.css', 'punctuation.section.property-list.end.css']

        it 'tokenises comments between media features', ->
          {tokens} = grammar.tokenizeLine('@media/*=*/(max-width:/**/37.5em)/*=*/and/*=*/(/*=*/min-height/*:*/:/*=*/1.2em/*;*/){}')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'media', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']
          expect(tokens[2]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[3]).toEqual value: '=', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
          expect(tokens[4]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[5]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.begin.bracket.round.css']
          expect(tokens[6]).toEqual value: 'max-width', scopes: ['source.css', 'meta.at-rule.media.css', 'support.type.property-name.media.css']
          expect(tokens[7]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
          expect(tokens[8]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[9]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[10]).toEqual value: '37.5', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css']
          expect(tokens[11]).toEqual value: 'em', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css', 'keyword.other.unit.css']
          expect(tokens[12]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.end.bracket.round.css']
          expect(tokens[13]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[14]).toEqual value: '=', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
          expect(tokens[15]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[16]).toEqual value: 'and', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.operator.logical.and.media.css']
          expect(tokens[17]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[18]).toEqual value: '=', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
          expect(tokens[19]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[20]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.begin.bracket.round.css']
          expect(tokens[21]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[22]).toEqual value: '=', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
          expect(tokens[23]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[24]).toEqual value: 'min-height', scopes: ['source.css', 'meta.at-rule.media.css', 'support.type.property-name.media.css']
          expect(tokens[25]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[26]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
          expect(tokens[27]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[28]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
          expect(tokens[29]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[30]).toEqual value: '=', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
          expect(tokens[31]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[32]).toEqual value: '1.2', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css']
          expect(tokens[33]).toEqual value: 'em', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css', 'keyword.other.unit.css']
          expect(tokens[34]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[35]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
          expect(tokens[36]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[37]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.end.bracket.round.css']
          expect(tokens[38]).toEqual value: '{', scopes: ['source.css', 'punctuation.section.property-list.begin.css']
          expect(tokens[39]).toEqual value: '}', scopes: ['source.css', 'punctuation.section.property-list.end.css']

      it 'matches media queries across lines', ->
        lines = grammar.tokenizeLines """
          @media only screen and (min-width : /* 40 */
            320px),
            not print and (max-width: 480px)  /* kek */ and (-webkit-min-device-pixel-ratio /*:*/ : 2),
          only speech and (min-width: 10em),  /* wat */     (-webkit-min-device-pixel-ratio: 2) { }
        """
        expect(lines[0][0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
        expect(lines[0][1]).toEqual value: 'media', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']
        expect(lines[0][3]).toEqual value: 'only', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.operator.logical.only.media.css']
        expect(lines[0][5]).toEqual value: 'screen', scopes: ['source.css', 'meta.at-rule.media.css', 'support.constant.media.css']
        expect(lines[0][7]).toEqual value: 'and', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.operator.logical.and.media.css']
        expect(lines[0][9]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.begin.bracket.round.css']
        expect(lines[0][10]).toEqual value: 'min-width', scopes: ['source.css', 'meta.at-rule.media.css', 'support.type.property-name.media.css']
        expect(lines[0][12]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
        expect(lines[0][14]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
        expect(lines[0][15]).toEqual value: ' 40 ', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
        expect(lines[0][16]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
        expect(lines[1][1]).toEqual value: '320', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css']
        expect(lines[1][2]).toEqual value: 'px', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css', 'keyword.other.unit.css']
        expect(lines[1][3]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.end.bracket.round.css']
        expect(lines[1][4]).toEqual value: ',', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.delimiter.arbitrary-repetition.comma.css']
        expect(lines[2][1]).toEqual value: 'not', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.operator.logical.not.media.css']
        expect(lines[2][3]).toEqual value: 'print', scopes: ['source.css', 'meta.at-rule.media.css', 'support.constant.media.css']
        expect(lines[2][5]).toEqual value: 'and', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.operator.logical.and.media.css']
        expect(lines[2][7]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.begin.bracket.round.css']
        expect(lines[2][8]).toEqual value: 'max-width', scopes: ['source.css', 'meta.at-rule.media.css', 'support.type.property-name.media.css']
        expect(lines[2][9]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
        expect(lines[2][11]).toEqual value: '480', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css']
        expect(lines[2][12]).toEqual value: 'px', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css', 'keyword.other.unit.css']
        expect(lines[2][13]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.end.bracket.round.css']
        expect(lines[2][15]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
        expect(lines[2][16]).toEqual value: ' kek ', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
        expect(lines[2][17]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
        expect(lines[2][19]).toEqual value: 'and', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.operator.logical.and.media.css']
        expect(lines[2][21]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.begin.bracket.round.css']
        expect(lines[2][22]).toEqual value: '-webkit-min-device-pixel-ratio', scopes: ['source.css', 'meta.at-rule.media.css', 'support.type.vendored.property-name.media.css']
        expect(lines[2][24]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
        expect(lines[2][25]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
        expect(lines[2][26]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
        expect(lines[2][28]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
        expect(lines[2][30]).toEqual value: '2', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css']
        expect(lines[2][31]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.end.bracket.round.css']
        expect(lines[2][32]).toEqual value: ',', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.delimiter.arbitrary-repetition.comma.css']
        expect(lines[3][0]).toEqual value: 'only', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.operator.logical.only.media.css']
        expect(lines[3][2]).toEqual value: 'speech', scopes: ['source.css', 'meta.at-rule.media.css', 'support.constant.media.css']
        expect(lines[3][4]).toEqual value: 'and', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.operator.logical.and.media.css']
        expect(lines[3][6]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.begin.bracket.round.css']
        expect(lines[3][7]).toEqual value: 'min-width', scopes: ['source.css', 'meta.at-rule.media.css', 'support.type.property-name.media.css']
        expect(lines[3][8]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
        expect(lines[3][10]).toEqual value: '10', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css']
        expect(lines[3][11]).toEqual value: 'em', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css', 'keyword.other.unit.css']
        expect(lines[3][12]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.end.bracket.round.css']
        expect(lines[3][13]).toEqual value: ',', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.delimiter.arbitrary-repetition.comma.css']
        expect(lines[3][15]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
        expect(lines[3][16]).toEqual value: ' wat ', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
        expect(lines[3][17]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
        expect(lines[3][19]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.begin.bracket.round.css']
        expect(lines[3][20]).toEqual value: '-webkit-min-device-pixel-ratio', scopes: ['source.css', 'meta.at-rule.media.css', 'support.type.vendored.property-name.media.css']
        expect(lines[3][21]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
        expect(lines[3][23]).toEqual value: '2', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css']
        expect(lines[3][24]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.end.bracket.round.css']
        expect(lines[3][26]).toEqual value: '{', scopes: ['source.css', 'punctuation.section.property-list.begin.css']
        expect(lines[3][28]).toEqual value: '}', scopes: ['source.css', 'punctuation.section.property-list.end.css']

      it 'highlights invalid commas', ->
        {tokens} = grammar.tokenizeLine('@media , {}')
        expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
        expect(tokens[1]).toEqual value: 'media', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']
        expect(tokens[3]).toEqual value: ',', scopes: ['source.css', 'meta.at-rule.media.css', 'invalid.illegal.comma.css']
        expect(tokens[5]).toEqual value: '{', scopes: ['source.css', 'punctuation.section.property-list.begin.css']
        expect(tokens[6]).toEqual value: '}', scopes: ['source.css', 'punctuation.section.property-list.end.css']

        {tokens} = grammar.tokenizeLine('@media , ,screen {}')
        expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
        expect(tokens[1]).toEqual value: 'media', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']
        expect(tokens[3]).toEqual value: ', ,', scopes: ['source.css', 'meta.at-rule.media.css', 'invalid.illegal.comma.css']
        expect(tokens[4]).toEqual value: 'screen', scopes: ['source.css', 'meta.at-rule.media.css', 'support.constant.media.css']
        expect(tokens[6]).toEqual value: '{', scopes: ['source.css', 'punctuation.section.property-list.begin.css']
        expect(tokens[7]).toEqual value: '}', scopes: ['source.css', 'punctuation.section.property-list.end.css']

      describe '@namespace', ->
        it 'tokenises @namespace statements correctly', ->
          {tokens} = grammar.tokenizeLine('@namespace "XML";')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'namespace', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css']
          expect(tokens[2]).toEqual value: ' ', scopes: ['source.css', 'meta.at-rule.namespace.css']
          expect(tokens[3]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[4]).toEqual value: 'XML', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css']
          expect(tokens[5]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[6]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.namespace.css', 'punctuation.terminator.at-rule.css']

          {tokens} = grammar.tokenizeLine('@namespace  prefix  "XML"  ;')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'namespace', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css']
          expect(tokens[2]).toEqual value: '  ', scopes: ['source.css', 'meta.at-rule.namespace.css']
          expect(tokens[3]).toEqual value: 'prefix', scopes: ['source.css', 'meta.at-rule.namespace.css', 'entity.name.function.namespace-prefix.css']
          expect(tokens[4]).toEqual value: '  ', scopes: ['source.css', 'meta.at-rule.namespace.css']
          expect(tokens[5]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[6]).toEqual value: 'XML', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css']
          expect(tokens[7]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[8]).toEqual value: '  ', scopes: ['source.css', 'meta.at-rule.namespace.css']
          expect(tokens[9]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.namespace.css', 'punctuation.terminator.at-rule.css']

          {tokens} = grammar.tokenizeLine('@namespace url("http://a.bc/");')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'namespace', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css']
          expect(tokens[2]).toEqual value: ' ', scopes: ['source.css', 'meta.at-rule.namespace.css']
          expect(tokens[3]).toEqual value: 'url', scopes: ['source.css', 'meta.at-rule.namespace.css', 'support.function.misc.css']
          expect(tokens[4]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.namespace.css', 'punctuation.section.function.css']
          expect(tokens[5]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[6]).toEqual value: 'http://a.bc/', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css']
          expect(tokens[7]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[8]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.namespace.css', 'punctuation.section.function.css']
          expect(tokens[9]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.namespace.css', 'punctuation.terminator.at-rule.css']

        it "doesn't confuse a prefix of 'url' as a function", ->
          {tokens} = grammar.tokenizeLine('@namespace url url("http://a.bc/");')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'namespace', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css']
          expect(tokens[3]).toEqual value: 'url', scopes: ['source.css', 'meta.at-rule.namespace.css', 'entity.name.function.namespace-prefix.css']
          expect(tokens[5]).toEqual value: 'url', scopes: ['source.css', 'meta.at-rule.namespace.css', 'support.function.misc.css']
          expect(tokens[6]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.namespace.css', 'punctuation.section.function.css']
          expect(tokens[7]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[8]).toEqual value: 'http://a.bc/', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css']
          expect(tokens[9]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[10]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.namespace.css', 'punctuation.section.function.css']
          expect(tokens[11]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.namespace.css', 'punctuation.terminator.at-rule.css']

        it 'permits injected comments between tokens', ->
          {tokens} = grammar.tokenizeLine('@namespace/*=*/pre/*=*/"url"/*=*/;')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'namespace', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css']
          expect(tokens[2]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.namespace.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[3]).toEqual value: '=', scopes: ['source.css', 'meta.at-rule.namespace.css', 'comment.block.css']
          expect(tokens[4]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.namespace.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[5]).toEqual value: 'pre', scopes: ['source.css', 'meta.at-rule.namespace.css', 'entity.name.function.namespace-prefix.css']
          expect(tokens[6]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.namespace.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[7]).toEqual value: '=', scopes: ['source.css', 'meta.at-rule.namespace.css', 'comment.block.css']
          expect(tokens[8]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.namespace.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[9]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[10]).toEqual value: 'url', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css']
          expect(tokens[11]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[12]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.namespace.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[13]).toEqual value: '=', scopes: ['source.css', 'meta.at-rule.namespace.css', 'comment.block.css']
          expect(tokens[14]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.namespace.css', 'comment.block.css', 'punctuation.definition.comment.css']
          expect(tokens[15]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.namespace.css', 'punctuation.terminator.at-rule.css']

        it 'allows no spaces between "@namespace" and quoted URLs', ->
          {tokens} = grammar.tokenizeLine('@namespace"XML";')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'namespace', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css']
          expect(tokens[2]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[3]).toEqual value: 'XML', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css']
          expect(tokens[4]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[5]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.namespace.css', 'punctuation.terminator.at-rule.css']

        it 'allows arguments to span multiple lines', ->
          lines = grammar.tokenizeLines """
              @namespace
              prefix"XML";
          """
          expect(lines[0][0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css', 'punctuation.definition.keyword.css']
          expect(lines[0][1]).toEqual value: 'namespace', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css']
          expect(lines[0][2]).toEqual value: '', scopes: ['source.css', 'meta.at-rule.namespace.css']
          expect(lines[1][0]).toEqual value: 'prefix', scopes: ['source.css', 'meta.at-rule.namespace.css', 'entity.name.function.namespace-prefix.css']
          expect(lines[1][1]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(lines[1][2]).toEqual value: 'XML', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css']
          expect(lines[1][3]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(lines[1][4]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.namespace.css', 'punctuation.terminator.at-rule.css']

          lines = grammar.tokenizeLines """
              @namespace

                prefix

              url("http://a.bc/");
          """
          expect(lines[0][0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css', 'punctuation.definition.keyword.css']
          expect(lines[0][1]).toEqual value: 'namespace', scopes: ['source.css', 'meta.at-rule.namespace.css', 'keyword.control.at-rule.namespace.css']
          expect(lines[0][2]).toEqual value: '', scopes: ['source.css', 'meta.at-rule.namespace.css']
          expect(lines[1][0]).toEqual value: '', scopes: ['source.css', 'meta.at-rule.namespace.css']
          expect(lines[2][1]).toEqual value: 'prefix', scopes: ['source.css', 'meta.at-rule.namespace.css', 'entity.name.function.namespace-prefix.css']
          expect(lines[3][0]).toEqual value: '', scopes: ['source.css', 'meta.at-rule.namespace.css']
          expect(lines[4][0]).toEqual value: 'url', scopes: ['source.css', 'meta.at-rule.namespace.css', 'support.function.misc.css']
          expect(lines[4][1]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.namespace.css', 'punctuation.section.function.css']
          expect(lines[4][2]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(lines[4][3]).toEqual value: 'http://a.bc/', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css']
          expect(lines[4][4]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.namespace.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(lines[4][5]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.namespace.css', 'punctuation.section.function.css']
          expect(lines[4][6]).toEqual value: ';', scopes: ['source.css', 'meta.at-rule.namespace.css', 'punctuation.terminator.at-rule.css']

      describe '@page', ->
        it 'tokenises @page blocks correctly', ->
          {tokens} = grammar.tokenizeLine('@page :first { }')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.page.css', 'keyword.control.at-rule.page.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'page', scopes: ['source.css', 'meta.at-rule.page.css', 'keyword.control.at-rule.page.css']
          expect(tokens[3]).toEqual value: ':', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
          expect(tokens[4]).toEqual value: 'first', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css']
          expect(tokens[6]).toEqual value: '{', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
          expect(tokens[8]).toEqual value: '}', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

          {tokens} = grammar.tokenizeLine('@page:right{}')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.page.css', 'keyword.control.at-rule.page.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'page', scopes: ['source.css', 'meta.at-rule.page.css', 'keyword.control.at-rule.page.css']
          expect(tokens[2]).toEqual value: ':', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
          expect(tokens[3]).toEqual value: 'right', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css']
          expect(tokens[4]).toEqual value: '{', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
          expect(tokens[5]).toEqual value: '}', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

          {tokens} = grammar.tokenizeLine('@page{}')
          expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.page.css', 'keyword.control.at-rule.page.css', 'punctuation.definition.keyword.css']
          expect(tokens[1]).toEqual value: 'page', scopes: ['source.css', 'meta.at-rule.page.css', 'keyword.control.at-rule.page.css']
          expect(tokens[2]).toEqual value: '{', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
          expect(tokens[3]).toEqual value: '}', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

    describe 'pseudo-classes', ->
      it 'tokenizes regular pseudo-classes', ->
        {tokens} = grammar.tokenizeLine 'p:first-child'
        expect(tokens[0]).toEqual value: 'p', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.css']
        expect(tokens[1]).toEqual value: ':', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
        expect(tokens[2]).toEqual value: 'first-child', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css']

      describe ':lang()', ->
        it 'tokenizes :lang()', ->
          {tokens} = grammar.tokenizeLine ':lang(zh-Hans-CN,es-419)'
          expect(tokens[0]).toEqual value: ':', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
          expect(tokens[1]).toEqual value: 'lang', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css']
          expect(tokens[2]).toEqual value: '(', scopes: ['source.css', 'meta.selector.css', 'punctuation.section.function.css']
          expect(tokens[3]).toEqual value: 'zh-Hans-CN', scopes: ['source.css', 'meta.selector.css', 'support.constant.language-range.css']
          expect(tokens[4]).toEqual value: ',', scopes: ['source.css', 'meta.selector.css', 'punctuation.separator.css']
          expect(tokens[5]).toEqual value: 'es-419', scopes: ['source.css', 'meta.selector.css', 'support.constant.language-range.css']
          expect(tokens[6]).toEqual value: ')', scopes: ['source.css', 'meta.selector.css', 'punctuation.section.function.css']

        it 'does not tokenize unquoted language ranges containing asterisks', ->
          {tokens} = grammar.tokenizeLine ':lang(zh-*-CN)'
          expect(tokens[3]).toEqual value: 'zh-*-CN', scopes: ['source.css', 'meta.selector.css']

        it 'tokenizes language ranges containing asterisks quoted as strings', ->
          {tokens} = grammar.tokenizeLine ':lang("zh-*-CN",\'*-ab-\')'
          expect(tokens[3]).toEqual value: '"', scopes: ['source.css', 'meta.selector.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[4]).toEqual value: 'zh-*-CN', scopes: ['source.css', 'meta.selector.css', 'string.quoted.double.css', 'support.constant.language-range.css']
          expect(tokens[5]).toEqual value: '"', scopes: ['source.css', 'meta.selector.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[6]).toEqual value: ',', scopes: ['source.css', 'meta.selector.css', 'punctuation.separator.css']
          expect(tokens[7]).toEqual value: "'", scopes: ['source.css', 'meta.selector.css', 'string.quoted.single.css', 'punctuation.definition.string.begin.css']
          expect(tokens[8]).toEqual value: '*-ab-', scopes: ['source.css', 'meta.selector.css', 'string.quoted.single.css', 'support.constant.language-range.css']
          expect(tokens[9]).toEqual value: "'", scopes: ['source.css', 'meta.selector.css', 'string.quoted.single.css', 'punctuation.definition.string.end.css']

      describe ':nth-*()', ->
        it 'tokenizes :nth-child()', ->
          tokens = grammar.tokenizeLines '''
            :nth-child(2n+1)
            :nth-child(2n -1)
            :nth-child(-2n+ 1)
            :nth-child(-2n - 1)
            :nth-child(odd)
          '''
          expect(tokens[0][0]).toEqual value: ':', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
          expect(tokens[0][1]).toEqual value: 'nth-child', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css']
          expect(tokens[0][2]).toEqual value: '(', scopes: ['source.css', 'meta.selector.css', 'punctuation.section.function.css']
          expect(tokens[0][3]).toEqual value: '2n+1', scopes: ['source.css', 'meta.selector.css', 'constant.numeric.css']
          expect(tokens[0][4]).toEqual value: ')', scopes: ['source.css', 'meta.selector.css', 'punctuation.section.function.css']
          expect(tokens[1][3]).toEqual value: '2n -1', scopes: ['source.css', 'meta.selector.css', 'constant.numeric.css']
          expect(tokens[2][3]).toEqual value: '-2n+ 1', scopes: ['source.css', 'meta.selector.css', 'constant.numeric.css']
          expect(tokens[3][3]).toEqual value: '-2n - 1', scopes: ['source.css', 'meta.selector.css', 'constant.numeric.css']
          expect(tokens[4][3]).toEqual value: 'odd', scopes: ['source.css', 'meta.selector.css', 'support.constant.parity.css']

        it 'tokenizes :nth-last-child()', ->
          tokens = grammar.tokenizeLines '''
            :nth-last-child(2n)
            :nth-last-child( -2n)
            :nth-last-child( 2n )
            :nth-last-child(even)
          '''
          expect(tokens[0][0]).toEqual value: ':', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
          expect(tokens[0][1]).toEqual value: 'nth-last-child', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css']
          expect(tokens[0][2]).toEqual value: '(', scopes: ['source.css', 'meta.selector.css', 'punctuation.section.function.css']
          expect(tokens[0][3]).toEqual value: '2n', scopes: ['source.css', 'meta.selector.css', 'constant.numeric.css']
          expect(tokens[0][4]).toEqual value: ')', scopes: ['source.css', 'meta.selector.css', 'punctuation.section.function.css']
          expect(tokens[1][4]).toEqual value: '-2n', scopes: ['source.css', 'meta.selector.css', 'constant.numeric.css']
          expect(tokens[2][4]).toEqual value: '2n', scopes: ['source.css', 'meta.selector.css', 'constant.numeric.css']
          expect(tokens[2][6]).toEqual value: ')', scopes: ['source.css', 'meta.selector.css', 'punctuation.section.function.css']
          expect(tokens[3][3]).toEqual value: 'even', scopes: ['source.css', 'meta.selector.css', 'support.constant.parity.css']

        it 'tokenizes :nth-of-type()', ->
          tokens = grammar.tokenizeLines '''
            img:nth-of-type(+n+1)
            img:nth-of-type(-n+1)
            img:nth-of-type(n+1)
          '''
          expect(tokens[0][1]).toEqual value: ':', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
          expect(tokens[0][2]).toEqual value: 'nth-of-type', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css']
          expect(tokens[0][3]).toEqual value: '(', scopes: ['source.css', 'meta.selector.css', 'punctuation.section.function.css']
          expect(tokens[0][4]).toEqual value: '+n+1', scopes: ['source.css', 'meta.selector.css', 'constant.numeric.css']
          expect(tokens[0][5]).toEqual value: ')', scopes: ['source.css', 'meta.selector.css', 'punctuation.section.function.css']
          expect(tokens[1][4]).toEqual value: '-n+1', scopes: ['source.css', 'meta.selector.css', 'constant.numeric.css']
          expect(tokens[2][4]).toEqual value: 'n+1', scopes: ['source.css', 'meta.selector.css', 'constant.numeric.css']

        it 'tokenizes ::nth-last-of-type()', ->
          tokens = grammar.tokenizeLines '''
            h1:nth-last-of-type(-1)
            h1:nth-last-of-type(+2)
            h1:nth-last-of-type(3)
          '''
          expect(tokens[0][1]).toEqual value: ':', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
          expect(tokens[0][2]).toEqual value: 'nth-last-of-type', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css']
          expect(tokens[0][3]).toEqual value: '(', scopes: ['source.css', 'meta.selector.css', 'punctuation.section.function.css']
          expect(tokens[0][4]).toEqual value: '-1', scopes: ['source.css', 'meta.selector.css', 'constant.numeric.css']
          expect(tokens[0][5]).toEqual value: ')', scopes: ['source.css', 'meta.selector.css', 'punctuation.section.function.css']
          expect(tokens[1][4]).toEqual value: '+2', scopes: ['source.css', 'meta.selector.css', 'constant.numeric.css']
          expect(tokens[2][4]).toEqual value: '3', scopes: ['source.css', 'meta.selector.css', 'constant.numeric.css']

    describe 'pseudo-elements', ->
      # :first-line, :first-letter, :before and :after
      it 'tokenizes both : and :: notations for pseudo-elements introduced in CSS 1 and 2', ->
        {tokens} = grammar.tokenizeLine '.opening:first-letter'
        expect(tokens[0]).toEqual value: '.', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: 'opening', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.class.css']
        expect(tokens[2]).toEqual value: ':', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css', 'punctuation.definition.entity.css']
        expect(tokens[3]).toEqual value: 'first-letter', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css']

        {tokens} = grammar.tokenizeLine 'q::after'
        expect(tokens[0]).toEqual value: 'q', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.css']
        expect(tokens[1]).toEqual value: '::', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css', 'punctuation.definition.entity.css']
        expect(tokens[2]).toEqual value: 'after', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css']

      it 'tokenizes both : and :: notations for vendor-prefixed pseudo-elements', ->
        {tokens} = grammar.tokenizeLine ':-ms-input-placeholder'
        expect(tokens[0]).toEqual value: ':', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: '-ms-input-placeholder', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css']

        {tokens} = grammar.tokenizeLine '::-webkit-input-placeholder'
        expect(tokens[0]).toEqual value: '::', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: '-webkit-input-placeholder', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css']

      it 'only tokenizes the :: notation for other pseudo-elements', ->
        {tokens} = grammar.tokenizeLine '::selection'
        expect(tokens[0]).toEqual value: '::', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css', 'punctuation.definition.entity.css']
        expect(tokens[1]).toEqual value: 'selection', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css']

        {tokens} = grammar.tokenizeLine ':selection'
        expect(tokens[0]).toEqual value: ':selection', scopes: ['source.css', 'meta.selector.css']

    describe 'compound selectors', ->
      it 'tokenizes the combination of type selectors followed by class selectors', ->
        {tokens} = grammar.tokenizeLine 'very-custom.class'
        expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
        expect(tokens[1]).toEqual value: '.', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
        expect(tokens[2]).toEqual value: 'class', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.class.css']

      it 'tokenizes the combination of type selectors followed by pseudo-classes', ->
        {tokens} = grammar.tokenizeLine 'very-custom:hover'
        expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
        expect(tokens[1]).toEqual value: ':', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
        expect(tokens[2]).toEqual value: 'hover', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css']

      it 'tokenizes the combination of type selectors followed by pseudo-elements', ->
        {tokens} = grammar.tokenizeLine 'very-custom::shadow'
        expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
        expect(tokens[1]).toEqual value: '::', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css', 'punctuation.definition.entity.css']
        expect(tokens[2]).toEqual value: 'shadow', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-element.css']

  describe 'property lists (declaration blocks)', ->
    it 'tokenizes inline property lists', ->
      {tokens} = grammar.tokenizeLine 'div { font-size: inherit; }'
      expect(tokens[4]).toEqual value: 'font-size', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(tokens[5]).toEqual value: ':', scopes: ['source.css', 'meta.property-list.css', 'punctuation.separator.key-value.css']
      expect(tokens[6]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css']
      expect(tokens[7]).toEqual value: 'inherit', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
      expect(tokens[8]).toEqual value: ';', scopes: ['source.css', 'meta.property-list.css', 'punctuation.terminator.rule.css']
      expect(tokens[10]).toEqual value: '}', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

    it 'tokenizes compact inline property lists', ->
      {tokens} = grammar.tokenizeLine 'div{color:inherit;float:left}'
      expect(tokens[2]).toEqual value: 'color', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(tokens[3]).toEqual value: ':', scopes: ['source.css', 'meta.property-list.css', 'punctuation.separator.key-value.css']
      expect(tokens[4]).toEqual value: 'inherit', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
      expect(tokens[5]).toEqual value: ';', scopes: ['source.css', 'meta.property-list.css', 'punctuation.terminator.rule.css']
      expect(tokens[6]).toEqual value: 'float', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(tokens[7]).toEqual value: ':', scopes: ['source.css', 'meta.property-list.css', 'punctuation.separator.key-value.css']
      expect(tokens[8]).toEqual value: 'left', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
      expect(tokens[9]).toEqual value: '}', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

    it 'tokenizes multiple inline property lists', ->
      tokens = grammar.tokenizeLines '''
        very-custom { color: inherit }
        another-one  {  display  :  none  ;  }
      '''
      expect(tokens[0][0]).toEqual value: 'very-custom', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
      expect(tokens[0][4]).toEqual value: 'color', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(tokens[0][5]).toEqual value: ':', scopes: ['source.css', 'meta.property-list.css', 'punctuation.separator.key-value.css']
      expect(tokens[0][7]).toEqual value: 'inherit', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
      expect(tokens[0][8]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css']
      expect(tokens[0][9]).toEqual value: '}', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.end.css']
      expect(tokens[1][0]).toEqual value: 'another-one', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
      expect(tokens[1][4]).toEqual value: 'display', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(tokens[1][5]).toEqual value: '  ', scopes: ['source.css', 'meta.property-list.css']
      expect(tokens[1][6]).toEqual value: ':', scopes: ['source.css', 'meta.property-list.css', 'punctuation.separator.key-value.css']
      expect(tokens[1][8]).toEqual value: 'none', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
      expect(tokens[1][9]).toEqual value: '  ', scopes: ['source.css', 'meta.property-list.css']
      expect(tokens[1][10]).toEqual value: ';', scopes: ['source.css', 'meta.property-list.css', 'punctuation.terminator.rule.css']
      expect(tokens[1][12]).toEqual value: '}', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

    it 'tokenizes custom properties', ->
      {tokens} = grammar.tokenizeLine ':root { --white: #FFF; }'
      expect(tokens[5]).toEqual value: '--white', scopes: ['source.css', 'meta.property-list.css', 'variable.css']

    describe 'values', ->
      it 'tokenizes color keywords', ->
        {tokens} = grammar.tokenizeLine '#jon { color: snow; }'
        expect(tokens[8]).toEqual value: 'snow', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.color.w3c-extended-color-name.css']

      it 'tokenizes common font names', ->
        {tokens} = grammar.tokenizeLine 'p { font-family: Verdana, Helvetica, sans-serif; }'
        expect(tokens[7]).toEqual value: 'Verdana', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.font-name.css']
        expect(tokens[9]).toEqual value: 'Helvetica', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.font-name.css']
        expect(tokens[11]).toEqual value: 'sans-serif', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.font-name.css']

      it 'tokenizes predefined list style types', ->
        {tokens} = grammar.tokenizeLine 'ol.myth { list-style-type: cjk-earthly-branch }'
        expect(tokens[9]).toEqual value: 'cjk-earthly-branch', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.list-style-type.css']

      it 'tokenizes numeric values', ->
        {tokens} = grammar.tokenizeLine 'div { font-size: 14px; }'
        expect(tokens[7]).toEqual value: '14', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css']
        expect(tokens[8]).toEqual value: 'px', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css', 'keyword.other.unit.css']

      it 'does not tokenize invalid numeric values', ->
        {tokens} = grammar.tokenizeLine 'div { font-size: test14px; }'
        expect(tokens[7]).toEqual value: 'test14px', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css']

        {tokens} = grammar.tokenizeLine 'div { font-size: test-14px; }'
        expect(tokens[7]).toEqual value: 'test-14px', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css']

      it 'tokenizes vendor-prefixed values', ->
        {tokens} = grammar.tokenizeLine '.edge { cursor: -webkit-zoom-in; }'
        expect(tokens[8]).toEqual value: '-webkit-zoom-in', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']

        {tokens} = grammar.tokenizeLine '.edge { width: -moz-min-content; }'
        expect(tokens[8]).toEqual value: '-moz-min-content', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']

        {tokens} = grammar.tokenizeLine '.edge { display: -ms-grid; }'
        expect(tokens[8]).toEqual value: '-ms-grid', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']

      it 'tokenizes custom variables', ->
        {tokens} = grammar.tokenizeLine 'div { color: var(--primary-color) }'
        expect(tokens[9]).toEqual value: '--primary-color', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'variable.argument.css']

  describe 'escape sequences', ->
    it 'tokenizes escape sequences in single-quoted strings', ->
      {tokens} = grammar.tokenizeLine "very-custom { content: '\\c0ffee' }"

      expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
      expect(tokens[1]).toEqual value: ' ', scopes: ['source.css', 'meta.selector.css']
      expect(tokens[2]).toEqual value: '{', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
      expect(tokens[3]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css']
      expect(tokens[4]).toEqual value: 'content', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(tokens[5]).toEqual value: ':', scopes: ['source.css', 'meta.property-list.css', 'punctuation.separator.key-value.css']
      expect(tokens[6]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css']
      expect(tokens[7]).toEqual value: "'", scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.single.css', 'punctuation.definition.string.begin.css']
      expect(tokens[8]).toEqual value: '\\c0ffee', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.single.css', 'constant.character.escape.css']

    it 'tokenizes escape sequences in double-quoted strings', ->
      {tokens} = grammar.tokenizeLine 'very-custom { content: "\\c0ffee" }'

      expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
      expect(tokens[1]).toEqual value: ' ', scopes: ['source.css', 'meta.selector.css']
      expect(tokens[2]).toEqual value: '{', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
      expect(tokens[3]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css']
      expect(tokens[4]).toEqual value: 'content', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(tokens[5]).toEqual value: ':', scopes: ['source.css', 'meta.property-list.css', 'punctuation.separator.key-value.css']
      expect(tokens[6]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css']
      expect(tokens[7]).toEqual value: '"', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
      expect(tokens[8]).toEqual value: '\\c0ffee', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.double.css', 'constant.character.escape.css']

  describe 'comments', ->
    it 'tokenises comments inside @import statements', ->
      {tokens} = grammar.tokenizeLine('@import /* url("name"); */ "1.css";')
      expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css', 'punctuation.definition.keyword.css']
      expect(tokens[1]).toEqual value: 'import', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css']
      expect(tokens[3]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[4]).toEqual value: ' url("name"); ', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css']
      expect(tokens[5]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[7]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
      expect(tokens[8]).toEqual value: '1.css', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css']
      expect(tokens[9]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
      expect(tokens[10]).toEqual value: ';', scopes: ['source.css']

      {tokens} = grammar.tokenizeLine('@import/*";"*/ url("2.css");')
      expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css', 'punctuation.definition.keyword.css']
      expect(tokens[1]).toEqual value: 'import', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css']
      expect(tokens[2]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[3]).toEqual value: '";"', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css']
      expect(tokens[4]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[6]).toEqual value: 'url', scopes: ['source.css', 'meta.at-rule.import.css', 'support.function.url.css']
      expect(tokens[7]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.section.function.css']
      expect(tokens[8]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
      expect(tokens[9]).toEqual value: '2.css', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css']
      expect(tokens[10]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
      expect(tokens[11]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.section.function.css']
      expect(tokens[12]).toEqual value: ';', scopes: ['source.css']

      {tokens} = grammar.tokenizeLine('@import url("3.css") print /* url(";"); */;')
      expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css', 'punctuation.definition.keyword.css']
      expect(tokens[1]).toEqual value: 'import', scopes: ['source.css', 'meta.at-rule.import.css', 'keyword.control.at-rule.import.css']
      expect(tokens[3]).toEqual value: 'url', scopes: ['source.css', 'meta.at-rule.import.css', 'support.function.url.css']
      expect(tokens[4]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.section.function.css']
      expect(tokens[5]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
      expect(tokens[6]).toEqual value: '3.css', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css']
      expect(tokens[7]).toEqual value: '"', scopes: ['source.css', 'meta.at-rule.import.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
      expect(tokens[8]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.import.css', 'punctuation.section.function.css']
      expect(tokens[10]).toEqual value: 'print', scopes: ['source.css', 'meta.at-rule.import.css', 'support.constant.media.css']
      expect(tokens[12]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[13]).toEqual value: ' url(";"); ', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css']
      expect(tokens[14]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.import.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[15]).toEqual value: ';', scopes: ['source.css']

    it 'tokenises comments inside @font-face statements', ->
      {tokens} = grammar.tokenizeLine('@font-face/*"{;}"*/{}')
      expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.font-face.css', 'keyword.control.at-rule.font-face.css', 'punctuation.definition.keyword.css']
      expect(tokens[1]).toEqual value: 'font-face', scopes: ['source.css', 'meta.at-rule.font-face.css', 'keyword.control.at-rule.font-face.css']
      expect(tokens[2]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.font-face.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[3]).toEqual value: '"{;}"', scopes: ['source.css', 'meta.at-rule.font-face.css', 'comment.block.css']
      expect(tokens[4]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.font-face.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[5]).toEqual value: '{', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
      expect(tokens[6]).toEqual value: '}', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

    it 'tokenizes comments before media queries', ->
      {tokens} = grammar.tokenizeLine '/* comment */ @media'

      expect(tokens[0]).toEqual value: '/*', scopes: ['source.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[1]).toEqual value: ' comment ', scopes: ['source.css', 'comment.block.css']
      expect(tokens[2]).toEqual value: '*/', scopes: ['source.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[4]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
      expect(tokens[5]).toEqual value: 'media', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']

    it 'tokenizes comments after media queries', ->
      {tokens} = grammar.tokenizeLine '@media/* comment */ ()'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
      expect(tokens[1]).toEqual value: 'media', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']
      expect(tokens[2]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[3]).toEqual value: ' comment ', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
      expect(tokens[4]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']

    it 'tokenizes comments inside query lists', ->
      {tokens} = grammar.tokenizeLine '@media (max-height: 40em/* comment */)'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
      expect(tokens[1]).toEqual value: 'media', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']
      expect(tokens[3]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.begin.bracket.round.css']
      expect(tokens[4]).toEqual value: 'max-height', scopes: ['source.css', 'meta.at-rule.media.css', 'support.type.property-name.media.css']
      expect(tokens[5]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
      expect(tokens[7]).toEqual value: '40', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css']
      expect(tokens[8]).toEqual value: 'em', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css', 'keyword.other.unit.css']
      expect(tokens[9]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[10]).toEqual value: ' comment ', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
      expect(tokens[11]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[12]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.definition.parameters.end.bracket.round.css']

    it 'tokenizes inline comments', ->
      {tokens} = grammar.tokenizeLine 'section {border:4px/*padding:1px*/}'

      expect(tokens[0]).toEqual value: 'section', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.css']
      expect(tokens[1]).toEqual value: ' ', scopes: ['source.css', 'meta.selector.css']
      expect(tokens[2]).toEqual value: '{', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
      expect(tokens[3]).toEqual value: 'border', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(tokens[4]).toEqual value: ':', scopes: ['source.css', 'meta.property-list.css', 'punctuation.separator.key-value.css']
      expect(tokens[5]).toEqual value: '4', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css']
      expect(tokens[6]).toEqual value: 'px', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css', 'keyword.other.unit.css']
      expect(tokens[7]).toEqual value: '/*', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[8]).toEqual value: 'padding:1px', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'comment.block.css']
      expect(tokens[9]).toEqual value: '*/', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[10]).toEqual value: '}', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

    it 'tokenizes multi-line comments', ->
      lines = grammar.tokenizeLines """
        section {
          border:4px /*1px;
          padding:1px*/
      }
      """

      expect(lines[1][5]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css']
      expect(lines[1][6]).toEqual value: '/*', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(lines[1][7]).toEqual value: '1px;', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'comment.block.css']

      expect(lines[2][0]).toEqual value: '    padding:1px', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'comment.block.css']
      expect(lines[2][1]).toEqual value: '*/', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'comment.block.css', 'punctuation.definition.comment.css']

      expect(lines[3][0]).toEqual value: '}', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

  describe 'Animations', ->
    it 'does not confuse animation names with predefined keywords', ->
      tokens = grammar.tokenizeLines '''
        .animated {
          animation-name: orphan-black;
          animation-name: line-scale;
        }
      '''
      expect(tokens[1][4]).toEqual value: 'orphan-black', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css']
      expect(tokens[2][4]).toEqual value: 'line-scale', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css']

  describe 'Transforms', ->
    it 'tokenizes transform functions', ->
      tokens = grammar.tokenizeLines '''
        .transformed {
          transform: matrix(0, 1.5, -1.5, 0, 0, 100px);
          transform: rotate(90deg) translateX(100px) scale(1.5);
        }
      '''
      expect(tokens[1][1]).toEqual value: 'transform', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(tokens[1][2]).toEqual value: ':', scopes: ['source.css', 'meta.property-list.css', 'punctuation.separator.key-value.css']
      expect(tokens[1][4]).toEqual value: 'matrix', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.function.transform.css']
      expect(tokens[1][5]).toEqual value: '(', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.section.function.css']
      expect(tokens[1][6]).toEqual value: '0', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css']
      expect(tokens[1][7]).toEqual value: ',', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.css']
      expect(tokens[1][12]).toEqual value: '-1.5', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css']
      expect(tokens[1][22]).toEqual value: 'px', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css', 'keyword.other.unit.css']
      expect(tokens[1][23]).toEqual value: ')', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.section.function.css']
      expect(tokens[2][4]).toEqual value: 'rotate', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.function.transform.css']
      expect(tokens[2][10]).toEqual value: 'translateX', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.function.transform.css']
      expect(tokens[2][16]).toEqual value: 'scale', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.function.transform.css']

  describe "firstLineMatch", ->
    it "recognises Emacs modelines", ->
      valid = """
        #-*- CSS -*-
        #-*- mode: CSS -*-
        /* -*-css-*- */
        // -*- CSS -*-
        /* -*- mode:CSS -*- */
        // -*- font:bar;mode:CSS -*-
        // -*- font:bar;mode:CSS;foo:bar; -*-
        // -*-font:mode;mode:CSS-*-
        // -*- foo:bar mode: css bar:baz -*-
        " -*-foo:bar;mode:css;bar:foo-*- ";
        " -*-font-mode:foo;mode:css;foo-bar:quux-*-"
        "-*-font:x;foo:bar; mode : CsS; bar:foo;foooooo:baaaaar;fo:ba;-*-";
        "-*- font:x;foo : bar ; mode : cSS ; bar : foo ; foooooo:baaaaar;fo:ba-*-";
      """
      for line in valid.split /\n/
        expect(grammar.firstLineRegex.scanner.findNextMatchSync(line)).not.toBeNull()

      invalid = """
        /* --*css-*- */
        /* -*-- CSS -*-
        /* -*- -- CSS -*-
        /* -*- CSS -;- -*-
        // -*- CCSS -*-
        // -*- CSS; -*-
        // -*- css-stuff -*-
        /* -*- model:css -*-
        /* -*- indent-mode:css -*-
        // -*- font:mode;CSS -*-
        // -*- mode: -*- CSS
        // -*- mode: I-miss-plain-old-css -*-
        // -*-font:mode;mode:css--*-
      """
      for line in invalid.split /\n/
        expect(grammar.firstLineRegex.scanner.findNextMatchSync(line)).toBeNull()

    it "recognises Vim modelines", ->
      valid = """
        vim: se filetype=css:
        # vim: se ft=css:
        # vim: set ft=CSS:
        # vim: set filetype=CSS:
        # vim: ft=CSS
        # vim: syntax=CSS
        # vim: se syntax=css:
        # ex: syntax=CSS
        # vim:ft=css
        # vim600: ft=css
        # vim>600: set ft=css:
        # vi:noai:sw=3 ts=6 ft=CSS
        # vi::::::::::noai:::::::::::: ft=CSS
        # vim:ts=4:sts=4:sw=4:noexpandtab:ft=cSS
        # vi:: noai : : : : sw   =3 ts   =6 ft  =Css
        # vim: ts=4: pi sts=4: ft=CSS: noexpandtab: sw=4:
        # vim: ts=4 sts=4: ft=css noexpandtab:
        # vim:noexpandtab sts=4 ft=css ts=4
        # vim:noexpandtab:ft=css
        # vim:ts=4:sts=4 ft=css:noexpandtab:\x20
        # vim:noexpandtab titlestring=hi\|there\\\\ ft=css ts=4
      """
      for line in valid.split /\n/
        expect(grammar.firstLineRegex.scanner.findNextMatchSync(line)).not.toBeNull()

      invalid = """
        ex: se filetype=css:
        _vi: se filetype=CSS:
         vi: se filetype=CSS
        # vim set ft=css3
        # vim: soft=css
        # vim: clean-syntax=css:
        # vim set ft=css:
        # vim: setft=CSS:
        # vim: se ft=css backupdir=tmp
        # vim: set ft=css set cmdheight=1
        # vim:noexpandtab sts:4 ft:CSS ts:4
        # vim:noexpandtab titlestring=hi\\|there\\ ft=CSS ts=4
        # vim:noexpandtab titlestring=hi\\|there\\\\\\ ft=CSS ts=4
      """
      for line in invalid.split /\n/
        expect(grammar.firstLineRegex.scanner.findNextMatchSync(line)).toBeNull()
