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

  describe 'property-list', ->
    it 'tokenizes the property-name and property-value', ->
      {tokens} = grammar.tokenizeLine 'very-custom { color: inherit; }'
      expect(tokens[4]).toEqual value: 'color', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(tokens[7]).toEqual value: 'inherit', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
      expect(tokens[8]).toEqual value: ';', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.terminator.rule.css']
      expect(tokens[10]).toEqual value: '}', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

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

    it 'tokenizes an incomplete inline property-list', ->
      {tokens} = grammar.tokenizeLine 'very-custom { color: inherit}'
      expect(tokens[4]).toEqual value: 'color', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(tokens[7]).toEqual value: 'inherit', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
      expect(tokens[8]).toEqual value: '}', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.section.property-list.end.css']

    it 'tokenizes multiple lines of incomplete property-list', ->
      lines = grammar.tokenizeLines '''
        very-custom { color: inherit }
        another-one { display: none; }
      '''
      expect(lines[0][0]).toEqual value: 'very-custom', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
      expect(lines[0][4]).toEqual value: 'color', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(lines[0][7]).toEqual value: 'inherit', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'support.constant.property-value.css']
      expect(lines[0][9]).toEqual value: '}', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.section.property-list.end.css']

      expect(lines[1][0]).toEqual value: 'another-one', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
      expect(lines[1][10]).toEqual value: '}', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.end.css']

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

      {tokens} = grammar.tokenizeLine 'very-custom::shadow { color: red; }'
      expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
      expect(tokens[1]).toEqual value: '::', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css', 'punctuation.definition.entity.css']
      expect(tokens[2]).toEqual value: 'shadow', scopes: ['source.css', 'meta.selector.css', 'entity.other.attribute-name.pseudo-class.css']

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

  describe 'character escapes', ->
    it 'can handle long hexadecimal escape sequences in single-quoted strings', ->
      {tokens} = grammar.tokenizeLine "very-custom { content: '\\c0ffee' }"

      expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
      expect(tokens[1]).toEqual value: ' ', scopes: ['source.css', 'meta.selector.css']
      expect(tokens[2]).toEqual value: '{', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
      expect(tokens[3]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css']
      expect(tokens[4]).toEqual value: 'content', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(tokens[5]).toEqual value: ':', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
      expect(tokens[6]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css']
      expect(tokens[7]).toEqual value: "'", scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.single.css', 'punctuation.definition.string.begin.css']
      expect(tokens[8]).toEqual value: '\\c0ffee', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.single.css', 'constant.character.escape.css']

    it 'can handle long hexadecimal escape sequences in double-quoted strings', ->
      {tokens} = grammar.tokenizeLine 'very-custom { content: "\\c0ffee" }'

      expect(tokens[0]).toEqual value: 'very-custom', scopes: ['source.css', 'meta.selector.css', 'entity.name.tag.custom.css']
      expect(tokens[1]).toEqual value: ' ', scopes: ['source.css', 'meta.selector.css']
      expect(tokens[2]).toEqual value: '{', scopes: ['source.css', 'meta.property-list.css', 'punctuation.section.property-list.begin.css']
      expect(tokens[3]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css']
      expect(tokens[4]).toEqual value: 'content', scopes: ['source.css', 'meta.property-list.css', 'meta.property-name.css', 'support.type.property-name.css']
      expect(tokens[5]).toEqual value: ':', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'punctuation.separator.key-value.css']
      expect(tokens[6]).toEqual value: ' ', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css']
      expect(tokens[7]).toEqual value: '"', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.double.css', 'punctuation.definition.string.begin.css']
      expect(tokens[8]).toEqual value: '\\c0ffee', scopes: ['source.css', 'meta.property-list.css', 'meta.property-value.css', 'string.quoted.double.css', 'constant.character.escape.css']

  describe 'comments', ->
    it 'tokenizes comments before media selectors', ->
      {tokens} = grammar.tokenizeLine '/* comment */ @media'

      expect(tokens[0]).toEqual value: '/*', scopes: ['source.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[1]).toEqual value: ' comment ', scopes: ['source.css', 'comment.block.css']
      expect(tokens[2]).toEqual value: '*/', scopes: ['source.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[4]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
      expect(tokens[5]).toEqual value: 'media', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']

    it 'tokenizes comments after media selectors', ->
      {tokens} = grammar.tokenizeLine '@media/* comment */ ()'

      expect(tokens[0]).toEqual value: '@', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css', 'punctuation.definition.keyword.css']
      expect(tokens[1]).toEqual value: 'media', scopes: ['source.css', 'meta.at-rule.media.css', 'keyword.control.at-rule.media.css']
      expect(tokens[2]).toEqual value: '/*', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']
      expect(tokens[3]).toEqual value: ' comment ', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css']
      expect(tokens[4]).toEqual value: '*/', scopes: ['source.css', 'meta.at-rule.media.css', 'comment.block.css', 'punctuation.definition.comment.css']

    it 'tokenizes comments in arguments of selectors', ->
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
