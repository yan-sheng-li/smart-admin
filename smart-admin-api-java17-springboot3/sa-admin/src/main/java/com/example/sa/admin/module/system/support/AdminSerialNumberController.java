package com.example.sa.admin.module.system.support;

import cn.dev33.satoken.annotation.SaCheckPermission;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import com.example.sa.base.common.controller.SupportBaseController;
import com.example.sa.base.common.domain.PageResult;
import com.example.sa.base.common.domain.ResponseDTO;
import com.example.sa.base.common.util.SmartEnumUtil;
import com.example.sa.base.constant.SwaggerTagConst;
import com.example.sa.base.module.support.serialnumber.constant.SerialNumberIdEnum;
import com.example.sa.base.module.support.serialnumber.dao.SerialNumberDao;
import com.example.sa.base.module.support.serialnumber.domain.SerialNumberEntity;
import com.example.sa.base.module.support.serialnumber.domain.SerialNumberGenerateForm;
import com.example.sa.base.module.support.serialnumber.domain.SerialNumberRecordEntity;
import com.example.sa.base.module.support.serialnumber.domain.SerialNumberRecordQueryForm;
import com.example.sa.base.module.support.serialnumber.service.SerialNumberRecordService;
import com.example.sa.base.module.support.serialnumber.service.SerialNumberService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = SwaggerTagConst.Support.SERIAL_NUMBER)
@RestController
public class AdminSerialNumberController extends SupportBaseController {

    @Resource
    private SerialNumberDao serialNumberDao;

    @Resource
    private SerialNumberService serialNumberService;

    @Resource
    private SerialNumberRecordService serialNumberRecordService;

    @Operation(summary = "生成单号")
    @PostMapping("/serialNumber/generate")
    @SaCheckPermission("support:serialNumber:generate")
    public ResponseDTO<List<String>> generate(@RequestBody @Valid SerialNumberGenerateForm generateForm) {
        SerialNumberIdEnum serialNumberIdEnum = SmartEnumUtil.getEnumByValue(generateForm.getSerialNumberId(), SerialNumberIdEnum.class);
        if (null == serialNumberIdEnum) {
            return ResponseDTO.userErrorParam("SerialNumberId，不存在" + generateForm.getSerialNumberId());
        }
        return ResponseDTO.ok(serialNumberService.generate(serialNumberIdEnum, generateForm.getCount()));
    }

    @Operation(summary = "获取所有单号定义")
    @GetMapping("/serialNumber/all")
    public ResponseDTO<List<SerialNumberEntity>> getAll() {
        return ResponseDTO.ok(serialNumberDao.selectList(null));
    }

    @Operation(summary = "获取生成记录")
    @PostMapping("/serialNumber/queryRecord")
    @SaCheckPermission("support:serialNumber:record")
    public ResponseDTO<PageResult<SerialNumberRecordEntity>> queryRecord(@RequestBody @Valid SerialNumberRecordQueryForm queryForm) {
        return ResponseDTO.ok(serialNumberRecordService.query(queryForm));
    }

}
