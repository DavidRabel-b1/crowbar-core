#
# Copyright 2016, SUSE Linux GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Api::UpgradeController < ApiController
  before_action :set_upgrade

  def show
    render json: @upgrade.status
  end

  def update
    head :not_implemented
  end

  def prepare
    status = :ok
    msg = ""

    begin
      service_object = CrowbarService.new(Rails.logger)

      service_object.prepare_nodes_for_crowbar_upgrade
    rescue => e
      msg = e.message
      Rails.logger.error msg
      status = :unprocessable_entity
    end

    if status == :ok
      head status
    else
      render json: msg, status: status
    end
  end

  def services
    if request.post?
      head :not_implemented
    else
      render json: [], status: :not_implemented
    end
  end

  def prechecks
    render json: @upgrade.check
  end

  def cancel
    service_object = CrowbarService.new(Rails.logger)
    service_object.revert_nodes_from_crowbar_upgrade

    head :ok
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  protected

  def set_upgrade
    @upgrade = Api::Upgrade.new
  end
end
