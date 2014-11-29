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

  describe 'custom elements', ->
    it 'tokenizes them as tags', ->
      {tokens} = grammar.tokenizeLine 'very-custom { color: red; }'
      expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']

      {tokens} = grammar.tokenizeLine 'very-very-custom { color: red; }'
      expect(tokens[0]).toEqual value: 'very-very-custom', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']

    it 'tokenizes them with pseudo selectors', ->
      {tokens} = grammar.tokenizeLine 'very-custom:hover { color: red; }'
      expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
      expect(tokens[1]).toEqual value: ':', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
      expect(tokens[2]).toEqual value: 'hover', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css']

    it 'tokenizes them with class selectors', ->
      {tokens} = grammar.tokenizeLine 'very-custom.class { color: red; }'
      expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
      expect(tokens[1]).toEqual value: '.', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.class.css', 'punctuation.definition.entity.css']
      expect(tokens[2]).toEqual value: 'class', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.class.css']

    it 'does not confuse them with properties', ->
      lines = grammar.tokenizeLines """
        body {
          border-width: 2;
          font-size : 2;
          background-image  : none;
        }
      """

      expect(lines[1][0]).toEqual value: '  ', scopes: ['source.css', 'meta.property-list.css']
      expect(lines[1][1]).toEqual value: 'border-width', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(lines[1][2]).toEqual value: ':', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
      expect(lines[1][3]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css']
      expect(lines[1][4]).toEqual value: '2', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css']

      expect(lines[2][0]).toEqual value: '  ', scopes: ['source.css', 'meta.property-list.css']
      expect(lines[2][1]).toEqual value: 'font-size', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(lines[2][2]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css']
      expect(lines[2][3]).toEqual value: ':', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
      expect(lines[2][4]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css']
      expect(lines[2][5]).toEqual value: '2', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'constant.numeric.css']

      expect(lines[3][0]).toEqual value: '  ', scopes: ['source.css', 'meta.property-list.css']
      expect(lines[3][1]).toEqual value: 'background-image', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(lines[3][2]).toEqual value: '  ', scopes: ['source.css', 'meta.property-list.css']
      expect(lines[3][3]).toEqual value: ':', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
      expect(lines[3][4]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css']
      expect(lines[3][5]).toEqual value: 'none', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
