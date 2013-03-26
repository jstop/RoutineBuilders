require "spec_helper"

describe RoutinesController do
  describe "routing" do

    it "routes to #index" do
      get("/routines").should route_to("routines#index")
    end

    it "routes to #new" do
      get("/routines/new").should route_to("routines#new")
    end

    it "routes to #show" do
      get("/routines/1").should route_to("routines#show", :id => "1")
    end

    it "routes to #edit" do
      get("/routines/1/edit").should route_to("routines#edit", :id => "1")
    end

    it "routes to #create" do
      post("/routines").should route_to("routines#create")
    end

    it "routes to #update" do
      put("/routines/1").should route_to("routines#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/routines/1").should route_to("routines#destroy", :id => "1")
    end

  end
end
