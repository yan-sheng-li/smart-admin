import { postRequest, getRequest } from '@/lib/smart-request';
export const changeLogApi = {
  /**
   * 分页查询  @author  
   */
  queryPage: (param) => {
    return postRequest('/support/changeLog/queryPage', param);
  },

  /**
   * 详情  @author  
   */
  getDetail: (changeLogId) => {
    return getRequest(`/support/changeLog/getDetail/${changeLogId}`);
  },
};
