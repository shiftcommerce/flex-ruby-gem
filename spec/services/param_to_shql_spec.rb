require "spec_helper"
require "flex_commerce_api"

module FlexCommerce
  describe ParamToShql do

    let(:service) { FlexCommerce::ParamToShql.new(filter_params) }

    context '#param_to_shql' do

      context 'normal filter' do
        # So these would have come from checkboxes
        context 'with one checkbox checked' do
          let(:filter_params) { { "meta.colour"=>{"blue"=>"on"} } }
        
          it 'parses it to SHQL' do
            expect(service.call).to eq(
              { "or" => [{"meta.colour"=>{"eq"=>"blue"}}] }
            )
          end
        end

        context 'with two checkboxes checked, same facet' do
          let(:filter_params) { { "meta.colour"=>{"blue"=>"on", "red"=>"on"} } }
        
          it 'parses it to SHQL' do
            expect(service.call).to eq(
              { "or" => [{"meta.colour"=>{"eq"=>"blue"}},{"meta.colour"=>{"eq"=>"red"}}] }
            )
          end
        end

        #
        # I am relatively confident that the logic here is not as we want - one step at
        # a time though.
        #
        context 'with two checkboxes checked, different facets' do
          let(:filter_params) { { "meta.colour"=>{"blue"=>"on"}, "meta.size"=>{"12"=>"on"} } }
        
          it 'parses it to SHQL' do
            expect(service.call).to eq(
              { "or" => [{"meta.colour"=>{"eq"=>"blue"}},{"meta.size"=>{"eq"=>"12"}}] }
            )
          end
        end
      end

      context 'range filter' do
        context 'when blank values are passed in' do
          let(:filter_params) { { "variants.price"=>{"lt"=>""} } }
        
          it 'parses it to SHQL' do
            expect(service.call).to eq({"or"=>[]})
          end
        end

        context 'with only less than filled in' do
          let(:filter_params) { { "variants.price"=>{"lt"=>20} } }
        
          it 'parses it to SHQL' do
            expect(service.call).to eq(
              { "or" => [{"and"=>[{"variants.price"=>{"lt"=>20}}]}] }
            )
          end
        end

        context 'with only greater than filled in' do
          let(:filter_params) { { "variants.price"=>{"gt"=>10} } }
        
          it 'parses it to SHQL' do
            expect(service.call).to eq(
              { "or" => [{"and"=>[{"variants.price"=>{"gt"=>10}}]}] }
            )
          end
        end

        context 'with both greater and less than filled in' do
          let(:filter_params) { { "variants.price"=>{"gt"=>10, "lt"=>20} } }
        
          it 'parses it to SHQL' do
            expect(service.call).to eq(
              { "or" => [{"and"=>[{"variants.price"=>{"gt"=>10}}, {"variants.price"=>{"lt"=>20}}]}] }
            )
          end
        end
      end
    end
  end
end
