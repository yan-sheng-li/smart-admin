package com.example.sa.base.module.support.reload;

import jakarta.annotation.Resource;
import com.example.sa.base.common.util.SmartBeanUtil;
import com.example.sa.base.module.support.reload.core.AbstractSmartReloadCommand;
import com.example.sa.base.module.support.reload.core.domain.SmartReloadItem;
import com.example.sa.base.module.support.reload.core.domain.SmartReloadResult;
import com.example.sa.base.module.support.reload.dao.ReloadItemDao;
import com.example.sa.base.module.support.reload.dao.ReloadResultDao;
import com.example.sa.base.module.support.reload.domain.ReloadItemEntity;
import com.example.sa.base.module.support.reload.domain.ReloadResultEntity;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class ReloadCommand extends AbstractSmartReloadCommand {

    @Resource
    private ReloadItemDao reloadItemDao;

    @Resource
    private ReloadResultDao reloadResultDao;

    /**
     * 读取数据库中SmartReload项
     *
     * @return List<ReloadItem>
     */
    @Override
    public List<SmartReloadItem> readReloadItem() {
        List<ReloadItemEntity> reloadItemEntityList = reloadItemDao.selectList(null);
        return SmartBeanUtil.copyList(reloadItemEntityList, SmartReloadItem.class);
    }

    /**
     * 保存reload结果
     *
     * @param smartReloadResult
     */
    @Override
    public void handleReloadResult(SmartReloadResult smartReloadResult) {
        ReloadResultEntity reloadResultEntity = SmartBeanUtil.copy(smartReloadResult, ReloadResultEntity.class);
        reloadResultDao.insert(reloadResultEntity);
    }
}
