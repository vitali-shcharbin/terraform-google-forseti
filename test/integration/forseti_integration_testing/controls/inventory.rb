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
    
    describe "Inventory create command is automated" do
        subject do 
            command("mysql -u root --host 127.0.0.1 --database forseti_security --execute \"select count(DISTINCT resource_id) from gcp_inventory where category='resource' and resource_type = 'project';\"")
        end
        before do 
            command("forseti inventory create").result
            command("sudo apt-get -y install mysql-client").result
        end
        its("exit_status") { should eq 0 }
        its("stdout") { should match "2" }
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

    describe "Explain list members command is automated" do
        subject do 
            command("forseti explainer list_members --prefix rdevani")
        end
        before do 
            command("forseti model create --inventory_index_id #{inventory_id} model_new").result
            command("forseti model use model_new").result
        end

        let :inventory_id do
            command("forseti inventory create").result
            JSON.parse(command("forseti inventory list").stdout).fetch("id")
        end

        its("exit_status") { should eq 0 }
        its("stdout") { should match /rdevani@google.com/ }
        its("stderr") { should eq ""}
        
        after do 
            command("forseti inventory purge 0").result
            command("forseti model delete model_new")
        end
    end

    describe "Explain list IAM roles command is automated" do
        subject do 
            command("forseti explainer list_roles --prefix roles/iam")
        end
        before do 
            command("forseti model create --inventory_index_id #{inventory_id} model_new").result
            command("forseti model use model_new").result
        end

        let :inventory_id do
            command("forseti inventory create").result
            JSON.parse(command("forseti inventory list").stdout).fetch("id")
        end

        its("exit_status") { should eq 0 }
        its("stdout") { should match /roles\/iam.securityAdmin/ }
        its("stderr") { should eq ""}
        
        after do 
            command("forseti inventory purge 0").result
            command("forseti model delete model_new")
        end
    end

    describe "Explain list Storage roles command is automated" do
        subject do 
            command("forseti explainer list_roles --prefix roles/storage")
        end
        before do 
            command("forseti model create --inventory_index_id #{inventory_id} model_new").result
            command("forseti model use model_new").result
        end

        let :inventory_id do
            command("forseti inventory create").result
            JSON.parse(command("forseti inventory list").stdout).fetch("id")
        end

        its("exit_status") { should eq 0 }
        its("stdout") { should match /roles\/storage.objectAdmin/ }
        its("stderr") { should eq ""}
        
        after do 
            command("forseti inventory purge 0").result
            command("forseti model delete model_new")
        end
    end
    
    describe "Explain list IAM roleAdmin permissions command is automated" do
        subject do 
            command("forseti explainer list_permissions --roles roles/iam.roleAdmin")
        end
    
        before(:context) do 
            command("forseti inventory create").result
            inventory_id = JSON.parse(command("forseti inventory list").stdout).fetch("id")
            command("forseti model create --inventory_index_id #{inventory_id} model_new").result
            command("forseti model use model_new").result
        end
    
        its("exit_status") { should eq 0 }
        its("stdout") { should match /roles.create/ }
        its("stdout") { should match /roles.delete/ }
        its("stdout") { should match /roles.get/ }
        its("stdout") { should match /roles.list/ }
        its("stdout") { should match /roles.undelete/ }
        its("stdout") { should match /roles.update/ }
        its("stdout") { should match /resourcemanager.projects.get/ }
        its("stdout") { should match /resourcemanager.projects.getIamPolicy/ }
        its("stderr") { should eq ""}
        
        after(:context) do 
            command("forseti inventory purge 0").result
            command("forseti model delete model_new")
        end
    end

    describe "Explain list IAM storage.Admin permissions command is automated" do
        subject do 
            command("forseti explainer list_permissions --roles roles/storage.Admin")
        end
    
        before(:context) do 
            command("forseti inventory create").result
            inventory_id = JSON.parse(command("forseti inventory list").stdout).fetch("id")
            command("forseti model create --inventory_index_id #{inventory_id} model_new").result
            command("forseti model use model_new").result
        end
    
        its("exit_status") { should eq 0 }
        its("stdout") { should match /firebase.projects.get/ }
        its("stdout") { should match /resourcemanager.projects.get/ }
        its("stdout") { should match /resourcemanager.projects.list/ }
        its("stdout") { should match /storage.buckets.create/}
        its("stdout") { should match /storage.buckets.delete/}
        its("stdout") { should match /storage.buckets.get/}
        its("stdout") { should match /storage.buckets.getIamPolicy/ }
        its("stdout") { should match /storage.buckets.list/}
        its("stdout") { should match /storage.buckets.setIamPolicy/}
        its("stdout") { should match /storage.buckets.update/ }
        its("stdout") { should match /storage.objects.create/ }
        its("stdout") { should match /storage.objects.delete/ }
        its("stdout") { should match /storage.objects.get/ }
        its("stdout") { should match /storage.objects.getIamPolicy/ }
        its("stdout") { should match /storage.objects.list/ }
        its("stdout") { should match /storage.objects.setIamPolicy/ }
        its("stdout") { should match /storage.objects.update/ }
    
        after(:context) do 
            command("forseti inventory purge 0").result
            command("forseti model delete model_new")
        end
    end
end