package com.example.sa.admin.module.system.support;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.annotation.Resource;
import jakarta.validation.Valid;
import com.example.sa.base.common.controller.SupportBaseController;
import com.example.sa.base.common.domain.PageResult;
import com.example.sa.base.common.domain.ResponseDTO;
import com.example.sa.base.common.domain.ValidateList;
import com.example.sa.base.constant.SwaggerTagConst;
import com.example.sa.base.module.support.config.ConfigKeyEnum;
import com.example.sa.base.module.support.config.ConfigService;
import com.example.sa.base.module.support.securityprotect.domain.Level3ProtectConfigForm;
import com.example.sa.base.module.support.securityprotect.domain.LoginFailQueryForm;
import com.example.sa.base.module.support.securityprotect.domain.LoginFailVO;
import com.example.sa.base.module.support.securityprotect.service.Level3ProtectConfigService;
import com.example.sa.base.module.support.securityprotect.service.SecurityLoginService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;


@RestController
@Tag(name = SwaggerTagConst.Support.PROTECT)
public class AdminProtectController extends SupportBaseController {

    @Resource
    private SecurityLoginService securityLoginService;

    @Resource
    private Level3ProtectConfigService level3ProtectConfigService;

    @Resource
    private ConfigService configService;

    @Operation(summary = "分页查询")
    @PostMapping("/protect/loginFail/queryPage")
    public ResponseDTO<PageResult<LoginFailVO>> queryPage(@RequestBody @Valid LoginFailQueryForm queryForm) {
        return ResponseDTO.ok(securityLoginService.queryPage(queryForm));
    }

    @Operation(summary = "批量删除")
    @PostMapping("/protect/loginFail/batchDelete")
    public ResponseDTO<String> batchDelete(@RequestBody ValidateList<Long> idList) {
        return securityLoginService.batchDelete(idList);
    }

    @Operation(summary = "更新三级等保配置")
    @PostMapping("/protect/level3protect/updateConfig")
    public ResponseDTO<String> updateConfig(@RequestBody @Valid Level3ProtectConfigForm configForm) {
        return level3ProtectConfigService.updateLevel3Config(configForm);
    }

    @Operation(summary = "查询 三级等保配置")
    @GetMapping("/protect/level3protect/getConfig")
    public ResponseDTO<String> getConfig() {
        return ResponseDTO.ok(configService.getConfigValue(ConfigKeyEnum.LEVEL3_PROTECT_CONFIG));
    }
}
