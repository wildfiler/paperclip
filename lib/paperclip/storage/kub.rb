module Paperclip
  module Storage
    # The default place to store attachments is in the filesystem. Files on the local
    # filesystem can be very easily served by Apache without requiring a hit to your app.
    # They also can be processed more easily after they've been saved, as they're just
    # normal files. There are two Filesystem-specific options for has_attached_file:
    # * +path+: The location of the repository of attachments on disk. This can (and, in
    #   almost all cases, should) be coordinated with the value of the +url+ option to
    #   allow files to be saved into a place where Apache can serve them without
    #   hitting your app. Defaults to
    #   ":rails_root/public/:attachment/:id/:style/:basename.:extension"
    #   By default this places the files in the app's public directory which can be served
    #   directly. If you are using capistrano for deployment, a good idea would be to
    #   make a symlink to the capistrano-created system directory from inside your app's
    #   public directory.
    #   See Paperclip::Attachment#interpolate for more information on variable interpolaton.
    #     :path => "/var/app/attachments/:class/:id/:style/:basename.:extension"
    # * +override_file_permissions+: This allows you to override the file permissions for files
    #   saved by paperclip. If you set this to an explicit octal value (0755, 0644, etc) then
    #   that value will be used to set the permissions for an uploaded file. The default is 0666.
    #   If you set :override_file_permissions to false, the chmod will be skipped. This allows
    #   you to use paperclip on filesystems that don't understand unix file permissions, and has the
    #   added benefit of using the storage directories default umask on those that do.
    module Kub
      def self.extended base
        require 'httpclient'
        @client = HTTPClient.new
      end

      def exists?(style_name = default_style)
        if original_filename
          true
        else
          false
        end
      end

      def flush_writes #:nodoc:
        @queued_for_write.each do |style_name, file|
          put style_name, file
          file.rewind
        end

        after_flush_writes # allows attachment to clean up temp files

        @queued_for_write = {}
      end

      def flush_deletes #:nodoc:
        @queued_for_delete.each do |path|

        end
        @queued_for_delete = []
      end

      def copy_to_local_file(style, local_dest_path)
      end

      private

      def put style, file
        request 'put', 'filename' => style, 'upload' => file
      end

      def delete file
        request 'delete', 'filename' => file
      end

      def exist? file
        request 'exist', 'filename' => file
      end

      def request type, *options
        @client.post 'http://dev.kubgames.com.ua/s3/storage.php', { 'request' => type }.merge(options)
      end
    end

  end
end
