namespace :xdr do

  # As Hayashi adds more .x files, we'll need to update this array
  # Prior to launch, we should be separating our .x files into a separate
  # repo, and should be able to improve this integration.
  HAYASHI_XDR = [
                 "core/src/xdr/types.x",
                 "core/src/xdr/ledger-entries.x",
                 "core/src/xdr/transaction.x",
                 "core/src/xdr/ledger.x",
                 "core/src/xdr/overlay.x",
                 "core/src/xdr/scp.x",
                ]

  LOCAL_XDR_PATHS = HAYASHI_XDR.map{ |src| "xdr/" + File.basename(src) }

  task :update => [:download, :generate]

  task :download do
    require 'octokit'
    require 'base64'
    FileUtils.rm_rf "xdr/"
    FileUtils.mkdir_p "xdr"

    client = Octokit::Client.new(:netrc => true)

    HAYASHI_XDR.each do |src|
      local_path = "xdr/" + File.basename(src)
      encoded    = client.contents("vixledger/vixal", path: src, ref:"22ca3227294d11612dee01cdc71ee2a48f5dfed0").content
      decoded    = Base64.decode64 encoded

      IO.write(local_path, decoded)
    end
  end

  task :generate do
    require "pathname"
    require "xdrgen"
    require 'fileutils'
    FileUtils.rm_rf "generated"

    compilation = Xdrgen::Compilation.new(
      LOCAL_XDR_PATHS,
      output_dir: "generated",
      namespace:  "vixal-base-generated",
      language:   :ruby
    )
    compilation.compile
  end
end
