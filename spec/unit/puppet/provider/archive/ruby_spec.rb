# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
require 'spec_helper'

ruby_provider = Puppet::Type.type(:archive).provider(:ruby)

RSpec.describe ruby_provider do
  it_behaves_like 'an archive provider', ruby_provider

  describe 'ruby provider' do
    let(:name) { '/tmp/example.zip' }
    let(:resource_properties) do
      {
        name: name,
        source: 's3://home.lan/example.zip'
      }
    end
    let(:resource) { Puppet::Type::Archive.new(resource_properties) }
    let(:provider) { ruby_provider.new(resource) }

    let(:s3_download_options) do
      ['s3', 'cp', 's3://home.lan/example.zip', String]
    end

    before do
      allow(provider).to receive(:aws)
    end

    context 'default resource property' do
      it '#s3_download' do
        provider.s3_download(name)
        expect(provider).to have_received(:aws).with(s3_download_options)
      end

      it '#extract nothing' do
        expect(provider.extract).to be_nil
      end
    end

    describe '#checksum' do
      subject { provider.checksum }

      let(:url) { nil }
      let(:remote_hash) { nil }

      before do
        resource[:checksum_url] = url if url
        allow(PuppetX::Bodeco::Util).to receive(:content).\
          with(url, any_args).and_return(remote_hash)
      end

      context 'unset' do
        it { is_expected.to be_nil }
      end

      context 'with a url' do
        let(:url) { 'http://example.com/checksum' }

        context 'responds with hash' do
          let(:remote_hash) { 'a0c38e1aeb175201b0dacd65e2f37e187657050a' }

          it { is_expected.to eq('a0c38e1aeb175201b0dacd65e2f37e187657050a') }
        end

        context 'responds with hash and newline' do
          let(:remote_hash) { "a0c38e1aeb175201b0dacd65e2f37e187657050a\n" }

          it { is_expected.to eq('a0c38e1aeb175201b0dacd65e2f37e187657050a') }
        end

        context 'responds with `sha1sum README.md` output' do
          let(:remote_hash) { "a0c38e1aeb175201b0dacd65e2f37e187657050a  README.md\n" }

          it { is_expected.to eq('a0c38e1aeb175201b0dacd65e2f37e187657050a') }
        end

        context 'responds with `openssl dgst -hex -sha256 README.md` output' do
          let(:remote_hash) { "SHA256(README.md)= 8fa3f0ff1f2557657e460f0f78232679380a9bcdb8670e3dcb33472123b22428\n" }

          it { is_expected.to eq('8fa3f0ff1f2557657e460f0f78232679380a9bcdb8670e3dcb33472123b22428') }
        end
      end
    end

    describe 'download options' do
      let(:resource_properties) do
        {
          name: name,
          source: 's3://home.lan/example.zip',
          download_options: ['--region', 'eu-central-1']
        }
      end

      context 'default resource property' do
        it '#s3_download' do
          provider.s3_download(name)
          expect(provider).to have_received(:aws).with(s3_download_options << '--region' << 'eu-central-1')
        end
      end
    end

    describe 'checksum match' do
      let(:resource_properties) do
        {
          name: name,
          source: '/dev/null',
          checksum: 'da39a3ee5e6b4b0d3255bfef95601890afd80709',
          checksum_type: 'sha1',
        }
      end

      it 'does not raise an error' do
        provider.transfer_download(name)
      end
    end

    describe 'checksum mismatch' do
      let(:resource_properties) do
        {
          name: name,
          source: '/dev/null',
          checksum: '9edf7cd9dfa0d83cd992e5501a480ea502968f15109aebe9ba2203648f3014db',
          checksum_type: 'sha1',
        }
      end

      it 'raises PuppetError (Download file checksum mismatch)' do
        expect { provider.transfer_download(name) }.to raise_error(Puppet::Error, %r{Download file checksum mismatch})
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
