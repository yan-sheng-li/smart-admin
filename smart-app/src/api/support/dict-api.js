import { postRequest, getRequest } from '@/lib/smart-request';
export const dictApi = {
  // 分页查询数据字典KEY - @author 
  keyQuery: (param) => {
    return postRequest('/support/dict/key/query', param);
  },
  // 查询全部字典key - @author 
  queryAllKey: () => {
    return getRequest('/support/dict/key/queryAll');
  },
  /**
   * 分页查询数据字典value - @author 
   */
  valueQuery: (param) => {
    return postRequest('/support/dict/value/query', param);
  },
  // 数据字典KEY-添加- @author 
  keyAdd: (param) => {
    return postRequest('/support/dict/key/add', param);
  },
  // 分页查询数据字典value - @author 
  valueAdd: (param) => {
    return postRequest('/support/dict/value/add', param);
  },
  // 数据字典key-更新- @author 
  keyEdit: (param) => {
    return postRequest('/support/dict/key/edit', param);
  },
  // 数据字典Value-更新- @author 
  valueEdit: (param) => {
    return postRequest('/support/dict/value/edit', param);
  },
  // 数据字典key-删除- @author 
  keyDelete: (keyIdList) => {
    return postRequest('/support/dict/key/delete', keyIdList);
  },
  // 数据字典Value-删除- @author 
  valueDelete: (valueIdList) => {
    return postRequest('/support/dict/value/delete', valueIdList);
  },
  // 缓存刷新- @author 
  cacheRefresh: () => {
    return getRequest('/support/dict/cache/refresh');
  },
  // 数据字典-值列表- @author 
  valueList: (keyCode) => {
    return getRequest(`/support/dict/value/list/${keyCode}`);
  },
};
