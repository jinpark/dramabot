require 'test_helper'

class WebhooksControllerTest < ActionController::TestCase
  setup do
    @webhook = webhooks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:webhooks)
  end

  test "should create webhook" do
    assert_difference('Webhook.count') do
      post :create, webhook: {  }
    end

    assert_response 201
  end

  test "should show webhook" do
    get :show, id: @webhook
    assert_response :success
  end

  test "should update webhook" do
    put :update, id: @webhook, webhook: {  }
    assert_response 204
  end

  test "should destroy webhook" do
    assert_difference('Webhook.count', -1) do
      delete :destroy, id: @webhook
    end

    assert_response 204
  end
end
