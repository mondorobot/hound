require 'fast_spec_helper'
require 'app/rules/rule'
Dir['app/rules/*rule.rb'].each {|f| require f}
require 'app/models/style_guide'

describe StyleGuide do
  describe '#check' do
    context 'with invalid lines of code' do
      it 'has violations' do
        lines = ['trailing_whitespace = true ', "\tincorrect_indentation = true"]
        style_guide = StyleGuide.new

        style_guide.check(lines)

        expect(style_guide).to have(2).violations
        expect(style_guide.violations).to eq([
          ['TrailingWhitespaceRule', lines.first],
          ['IndentationRule', lines.last]
        ])
      end
    end

    context 'with valid lines of code' do
      it 'has no violations' do
        lines = ['good line of code']
        style_guide = StyleGuide.new

        style_guide.check(lines)

        expect(style_guide).to have(0).violations
      end
    end
  end
end