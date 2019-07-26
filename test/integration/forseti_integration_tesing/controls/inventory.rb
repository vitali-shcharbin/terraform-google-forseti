require 'json'
control 'inventory' do

    describe "Inventory create command are automated" do
        subject do
            command("forseti inventory list")
        end
        before do 
            command("forseti inventory create").result
        end
        its("exit_status") { should eq 0 }
        its("stdout") { should match /SUCCESS/}
        its("stderr") { should eq ""}
        after do 
            command("forseti inventory purge 0").result
        end     
    end    

    describe "Inventory purge command is automated" do
        subject do 
            command("forseti inventory purge 0")
        end
        before do 
            command("forseti inventory create").result
        end
        its("exit_status") { should eq 0 }
        its("stdout") { should match /purged/ }
        its("stderr") { should eq ""}   
    end

    describe "Inventory list command is automated" do
        subject do 
            command("forseti inventory list")
        end
        before do 
            command("forseti inventory create").result
        end
        its("exit_status") { should eq 0 }
        its("stdout") { should match "" }
        its("stderr") { should eq ""}  
        after do 
            command("forseti inventory purge 0").result
        end
    end

    describe "Inventory get command is automated" do
        subject do 
            command("forseti inventory get #{inventory_id}")
        end
        let :inventory_id do
            command("forseti inventory create").result
            JSON.parse(command("forseti inventory list").stdout).fetch("id")
        end
        its("exit_status") { should eq 0 }
        its("stdout") { should_not eq "" }
        its("stderr") { should eq ""}  
        after do 
            command("forseti inventory purge 0").result
        end
    end

    describe "Inventory delete command is automated" do
        subject do 
            command("forseti inventory delete #{inventory_id}")
        end
        let :inventory_id do
            command("forseti inventory create").result
            JSON.parse(command("forseti inventory list").stdout).fetch("id")
        end
        its("exit_status") { should eq 0 }
        # its("stdout") { should eq "" }
        its("stderr") { should eq ""}  
    end

    describe "Inventory and model create command is automated" do
        subject do 
            command("forseti model create --inventory_index_id #{inventory_id} model_new")
        end
        let :inventory_id do
            command("forseti inventory create").result
            JSON.parse(command("forseti inventory list").stdout).fetch("id")
        end

        its("exit_status") { should eq 0 }
        its("stdout") { should match /SUCCESS/ }
        its("stderr") { should eq ""}
        
        after do 
            command("forseti inventory purge 0").result
            command("forseti model delete model_new").result
        end
    end

    describe "Model get command is automated" do
        subject do 
            command("forseti model get model_new")
        end
        before do 
            command("forseti model create --inventory_index_id #{inventory_id} model_new").result
        end

        let :inventory_id do
            command("forseti inventory create").result
            JSON.parse(command("forseti inventory list").stdout).fetch("id")
        end

        its("exit_status") { should eq 0 }
        its("stdout") { should match "" }
        its("stderr") { should eq ""}
        
        after do 
            command("forseti inventory purge 0").result
            command("forseti model delete model_new").result
        end
    end

    describe "Model delete command is automated" do
        subject do 
            command("forseti model delete model_new")
        end
        before do 
            command("forseti model create --inventory_index_id #{inventory_id} model_new").result
        end

        let :inventory_id do
            command("forseti inventory create").result
            JSON.parse(command("forseti inventory list").stdout).fetch("id")
        end

        its("exit_status") { should eq 0 }
        its("stdout") { should match /SUCCESS/ }
        its("stderr") { should eq ""}
        
        after do 
            command("forseti inventory purge 0").result
        end
    end

    describe "Model list command is automated" do
        subject do 
            command("forseti model list")
        end
        before do 
            command("forseti model create --inventory_index_id #{inventory_id} model_new").result
        end

        let :inventory_id do
            command("forseti inventory create").result
            JSON.parse(command("forseti inventory list").stdout).fetch("id")
        end

        its("exit_status") { should eq 0 }
        its("stdout") { should match /SUCCESS/ }
        its("stderr") { should eq ""}
        
        after do 
            command("forseti inventory purge 0").result
            command("forseti model delete model_new").result
        end
    end

    describe "Scanner run command is automated" do
        subject do 
            command("forseti scanner run")
        its("exit_status") { should eq 0 }
        its("stdout") { should match "" }
        its("stderr") { should eq ""}
    end

    describe "Notifier run command is automated" do
        subject do 
            command("forseti notifier run")
        its("exit_status") { should eq 0 }
        its("stdout") { should match "" }
        its("stderr") { should eq ""}  
    end


    # describe "Ensure CAI exportes are stored in bucket" do
    #     subject do 
    #         command("gsutil ls -r gs://#{attribute("forseti-cai-storage-bucket")}/**")
    #     end
    #     before do 
    #         command("forseti inventory create").result
    #     end
    #     its("stdout") { should match /organization/ }
    #     its("stderr") { should eq ""}
    #     after do 
    #         command("forseti inventory purge 0").result
    #     end
    # end

end