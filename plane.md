# plane

[参考](https://www.cnblogs.com/zyly/p/17775867.html)

![image-20240204135457133](D:\markdown\image-20240204135457133.png)

![ima](D:\markdown\image-20240204114811652.png)

- `dev`：该plane所属的DRM设备；
- `head`：链表节点，用于将当前节点追加到drm_mode_config.plane_list链表；
- `name`：可读性良好的名称，可以被驱动程序覆盖；
- `mutex`：互斥锁，用于保存modset     plane state；
- `base`：该plane的基类，struct     drm_mode_object类型；
- `possible_crtcs`：plane可以绑定到的管道，由drm_crtc_mask()构建；
- `format_types`：plane支持的格式数组；
- `format_count`：format_types数组的大小；
- `format_default`：驱动程序没有为该plane提供支持的格式。仅由non-atomic     driver兼容性包装器使用；
- `modifiers`：该plane支持的修饰符数组；
- `modifier_count`：modifiers数组的大小。
- `crtc`：当前绑定的CRTC，仅对non-atomic     driver有意义。对于atomic driver，它被强制为NULL，atomic     driver应该检查drm_plane_state.crtc；
- `fb`：当前绑定的framebuffer，仅对non-atomic     driver有意义。对于atomic driver，它被强制为NULL，atomic     driver应该检查drm_plane_state.fb；
- `old_fb`：在模式设置进行中临时跟踪旧的帧缓冲。仅由non-atomic     driver使用，对于atomic driver，它被强制为NULL；
- `funcs`：plane控制函数；
- `properties`：用于跟踪plane的属性。
- `type`：plane的类型，详见enum     drm_plane_type；
- `index`：在mode_config.list中的位置，可用作数组索引。在plane的生命周期中保持不变；
- `helper_private`：中间层私有数据；
- `state`：当前的原子状态；
- `alpha_property`：表示plane的可选alpha属性，参见drm_plane_create_alpha_property()；
- `zpos_property`：表示plane的可选zpos属性，参见drm_plane_create_zpos_property()；
- `rotation_property`：表示plane的可选旋转属性，参见drm_plane_create_rotation_property()；
- `blend_mode_property`：表示plane的可选pixel     blend mode枚举属性；
- `color_encoding_property`：表示plane的可选COLOR_ENCODING枚举属性，用于指定非RGB格式的颜色编码。参见drm_plane_create_color_properties()；
- `color_range_property`：表示plane的可选COLOR_RANGE枚举属性，用于指定非RGB格式的颜色范围。参见drm_plane_create_color_properties()；
- `scaling_filter_property`：用于在缩放时应用特定滤镜的属性；
- `src_x、src_y、src_h和src_w`指定framebuffer的源区域；
- `crtc_x、crtc_y、crtc_h和crtc_w`指定其显示在crtc上的目标区域。
