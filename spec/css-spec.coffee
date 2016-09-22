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
      expect(tokens[1]).toEqual value: 'disabled', scopes: ["source.css", "meta.selector.css", "meta.attribute-selector.css", "entity.other.attribute-name.attribute.css"]
      expect(tokens[2]).toEqual value: ']', scopes: ["source.css", "meta.selector.css", "meta.attribute-selector.css", "punctuation.definition.entity.css"]
      expect(tokens[3]).toEqual value: ', ', scopes: ["source.css", "meta.selector.css"]
      expect(tokens[4]).toEqual value: '[', scopes: ["source.css", "meta.selector.css", "meta.attribute-selector.css", "punctuation.definition.entity.css"]
      expect(tokens[5]).toEqual value: 'disabled', scopes: ["source.css", "meta.selector.css", "meta.attribute-selector.css", "entity.other.attribute-name.attribute.css"]
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
          expect(tokens[3]).toEqual value: 'zh-Hans-CN', scopes: ['source.css', 'meta.selector.css', 'meta.language-ranges.css', 'support.constant.language-range.css']
          expect(tokens[4]).toEqual value: ',', scopes: ['source.css', 'meta.selector.css', 'meta.language-ranges.css', 'punctuation.separator.css']
          expect(tokens[5]).toEqual value: 'es-419', scopes: ['source.css', 'meta.selector.css', 'meta.language-ranges.css', 'support.constant.language-range.css']
          expect(tokens[6]).toEqual value: ')', scopes: ['source.css', 'meta.selector.css', 'punctuation.section.function.css']

        it 'does not tokenize unquoted language ranges containing asterisks', ->
          {tokens} = grammar.tokenizeLine ':lang(zh-*-CN)'
          expect(tokens[3]).toEqual value: 'zh-*-CN', scopes: ['source.css', 'meta.selector.css', 'meta.language-ranges.css']

        it 'tokenizes language ranges containing asterisks quoted as strings', ->
          {tokens} = grammar.tokenizeLine ':lang("zh-*-CN",\'*-ab-\')'
          expect(tokens[3]).toEqual value: '"', scopes: ['source.css', 'meta.selector.css', 'meta.language-ranges.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
          expect(tokens[4]).toEqual value: 'zh-*-CN', scopes: ['source.css', 'meta.selector.css', 'meta.language-ranges.css', 'string.quoted.double.css', 'support.constant.language-range.css']
          expect(tokens[5]).toEqual value: '"', scopes: ['source.css', 'meta.selector.css', 'meta.language-ranges.css', 'string.quoted.double.css', 'punctuation.definition.string.end.css']
          expect(tokens[6]).toEqual value: ',', scopes: ['source.css', 'meta.selector.css', 'meta.language-ranges.css', 'punctuation.separator.css']
          expect(tokens[7]).toEqual value: "'", scopes: ['source.css', 'meta.selector.css', 'meta.language-ranges.css', 'string.quoted.single.css', 'punctuation.definition.string.begin.css']
          expect(tokens[8]).toEqual value: '*-ab-', scopes: ['source.css', 'meta.selector.css', 'meta.language-ranges.css', 'string.quoted.single.css', 'support.constant.language-range.css']
          expect(tokens[9]).toEqual value: "'", scopes: ['source.css', 'meta.selector.css', 'meta.language-ranges.css', 'string.quoted.single.css', 'punctuation.definition.string.end.css']

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
      expect(tokens[3]).toEqual value: '(', scopes: ['source.css', 'meta.at-rule.media.css']
      expect(tokens[4]).toEqual value: 'max-height', scopes: ['source.css', 'meta.at-rule.media.css', 'support.type.property-name.media.css']
      expect(tokens[5]).toEqual value: ':', scopes: ['source.css', 'meta.at-rule.media.css', 'punctuation.separator.key-value.css']
      expect(tokens[7]).toEqual value: '40', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css']
      expect(tokens[8]).toEqual value: 'em', scopes: ['source.css', 'meta.at-rule.media.css', 'constant.numeric.css', 'keyword.other.unit.css']
      expect(tokens[9]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[10]).toEqual value: ' comment ', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
      expect(tokens[11]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[12]).toEqual value: ')', scopes: ['source.css', 'meta.at-rule.media.css']

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
