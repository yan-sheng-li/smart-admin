package com.example.sa.base.module.support.datatracer.manager;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.sa.base.module.support.datatracer.dao.DataTracerDao;
import com.example.sa.base.module.support.datatracer.domain.entity.DataTracerEntity;
import org.springframework.stereotype.Service;

@Service
public class DataTracerManger extends ServiceImpl<DataTracerDao, DataTracerEntity> {
}
