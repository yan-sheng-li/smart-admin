package com.example.sa.admin.module.system.datascope.strategy;

import com.example.sa.admin.module.system.datascope.constant.DataScopeViewTypeEnum;
import com.example.sa.admin.module.system.datascope.domain.DataScopeSqlConfig;

import java.util.Map;

public abstract class AbstractDataScopeStrategy {

    /**
     * 获取joinsql 字符串
     */
    public abstract String getCondition(DataScopeViewTypeEnum viewTypeEnum, Map<String, Object> paramMap, DataScopeSqlConfig sqlConfigDTO);
}
