#
# VagrantMySQL
#
# A helper for interfacing with MySQL from your Vagrantfile
#
# @author      Dan Bennett <http://about.me/d.bennett>
# @package     Vagrant\Helpers
# @version     1.0.0
# @license     BSD 3-Clause <http://opensource.org/licenses/BSD-3-Clause>
# @todo        function DocBlocks!!!!
# @todo        type-checking on parameters
# @todo        support DBs other than MySQL?
#
class VagrantMySQL
    # setup stuff
    def VagrantMySQL.init( _box=false, _user="root", _pass="" )
        @box = _box
        @user = _user
        @pass = _pass
        @files = Array.new
        @commands = Array.new
        return self
    end  # VagrantMySQL.init

    # run a single SQL file on the box
    def VagrantMySQL.runFile( _src, _box=@box, _user=@user, _pass=@pass )
        @box = @box == _box ? @box : _box
        @user = @user == _user ? @user : _user
        @pass = @pass == _pass ? @pass : _pass
        if @box
            file = _src.split( '/' ).last
            @box.vm.provision "file", source: _src, destination: "~/" + file
            @box.vm.provision "shell", inline: "mysql -u" + @user + " -p" + @pass + " < '/home/vagrant/" + file + "';"
        end
    end  # VagrantMySQL.runFile

    # add SQL files to the queue to run all at once
    def VagrantMySQL.queueFiles( _files )
        unless _files.kind_of?( Array )
            _files = [_files]
        end
        @files.concat( _files )
    end  # VagrantMySQL.queueFiles

    # process the file queue
    def VagrantMySQL.processFiles( _box=@box, _user=@user, _pass=@pass )
        @box = @box == _box ? @box : _box
        @user = @user == _user ? @user : _user
        @pass = @pass == _pass ? @pass : _pass
        if @box
            unless @files.empty?
                @files.each do |src|
                    file = src.split( '/' ).last
                    @box.vm.provision "file", source: src, destination: "~/" + file
                    @box.vm.provision "shell", inline: "mysql -u" + @user + " -p" + @pass + " < '/home/vagrant/" + file + "';"
                end
            end
        end
    end  # VagrantMySQL.processFiles

    # run a single SQL command
    def VagrantMySQL.runCommand( _command, _box=@box, _user=@user, _pass=@pass )
        @box = @box == _box ? @box : _box
        @user = @user == _user ? @user : _user
        @pass = @pass == _pass ? @pass : _pass
        if @box
            @box.vm.provision "shell", inline: "mysql -u" + @user + " -p" + @pass + " -e '" + _command + "';"
        end
    end  # VagrantMySQL.runCommand

    # add SQL commands to the queue to run all at once
    def VagrantMySQL.queueCommands( _commands )
        unless _commands.kind_of?( Array )
            _commands = [_commands]
        end
        @commands.concat( _commands )
    end  # VagrantMySQL.queueCommands

    # process the command queue
    def VagrantMySQL.processCommands( _box=@box, _user=@user, _pass=@pass )
        @box = @box == _box ? @box : _box
        @user = @user == _user ? @user : _user
        @pass = @pass == _pass ? @pass : _pass
        if @box
            unless @commands.empty?
                @commands.each do |command|
                    @box.vm.provision "shell", inline: "mysql -u" + @user + " -p" + @pass + " -e '" + command + "';"
                end
            end
        end
    end  # VagrantMySQL.processCommands

    # dump a local database to file, add it to the queue
    # requires calling VagrantMySQL.processFiles later
    def VagrantMySQL.dumpToFileQueue( _database, _local_user="root", _local_pass="" )
        _local_pass = "" === _local_pass ? "" : " -p" + _local_pass
        file = "#{File.dirname(__FILE__)}/" + _database + ".sql"
        ENV['PATH'] = ENV['PATH'] + ":/c/xampp/mysql/bin/"
        sql_response = system "/c/xampp/mysql/bin/mysqldump -u #{_local_user}#{_local_pass} #{_database} > #{file};"
        unless sql_response > 0
            queueFiles( file )
        end
    end # VagrantMySQL.dumpToFileQueue

    # dump a local database to file and run immediately
    def VagrantMySQL.dumpAndRun( _database, _local_user="root", _local_pass="", _box=@box, _user=@user, _pass=@pass )
        @box = @box == _box ? @box : _box
        @user = @user == _user ? @user : _user
        @pass = @pass == _pass ? @pass : _pass

        _local_pass = "" === _local_pass ? "" : " -p" + _local_pass
        file = "#{File.dirname(__FILE__)}/" + _database + ".sql"
        ENV['PATH'] = ENV['PATH'] + ":/c/xampp/mysql/bin/"
        sql_response = system "/c/xampp/mysql/bin/mysqldump -u #{_local_user}#{_local_pass} #{_database} > #{file};"
        unless sql_response > 0
            runFile( file )
        end
    end # VagrantMySQL.dumpAndRun

end  # class VagrantMySQL
