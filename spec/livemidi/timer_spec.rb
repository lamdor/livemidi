require File.join(File.dirname(__FILE__), *%w[.. spec_helper])
require 'livemidi/timer'

describe Timer do

  before :each do
    @mock_target = mock("Target")
    @timer = Timer.new(0.01)
  end

  it "should kick a specified job at a specfied time" do
    @mock_target.should_receive(:ready).once
    @timer.at(Time.now + 0.1) { @mock_target.ready }
    sleep 0.15
  end

  it "should run multiple jobs irregardless of time" do
    another_target = mock("Another target")
    @mock_target.should_receive(:ready).once
    another_target.should_receive(:ready).once
    @timer.at(Time.now + 0.1) { @mock_target.ready }
    @timer.at(Time.now + 0.05) { another_target.ready }
    sleep 0.15
  end

  it "should kick a specified job at a specfied time, but not jobs later" do
    another_target = mock("Another target")
    @mock_target.should_receive(:ready).once
    another_target.should_not_receive(:ready)
    @timer.at(Time.now + 0.1) { @mock_target.ready }
    @timer.at(Time.now + 0.2) { another_target.ready }
    sleep 0.15
  end
  
end
