#import "Headers.h"

#import "ColourOptionsController.h"

@interface ColourOptionsController ()
- (void)coloursView;
@end

static NSBundle *tweakBundle = nil;
#define LOCALIZED(str) [tweakBundle localizedStringForKey:str value:@"" table:nil]

static NSString *saveSettings = @"/var/mobile/Library/Preferences/com.lizynz.folderx.plist";

@implementation ColourOptionsController
- (instancetype)init {
    self = [super init];
    if (self) {
        tweakBundle = [NSBundle bundleWithPath:@"/var/jb/Library/PreferenceBundles/FolderX.bundle"];
    }
    return self;
}

- (void)loadView {
	[super loadView];
    [self coloursView];
    
    UIImage *xmarkImage = [UIImage systemImageNamed:@"checkmark.seal"];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithImage:xmarkImage style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.leftBarButtonItem = doneButton;
    
    double delayInSeconds = 0.5;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        [button setTitle:LOCALIZED(@"reset color") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(center) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationItem setTitleView:button];
    });
    
    UIImage *raysImage = [UIImage systemImageNamed:@"xmark.circle"];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithImage:raysImage style:UIBarButtonItemStylePlain target:self action:@selector(closeButton)];
    self.navigationItem.rightBarButtonItem = saveButton;

    self.supportsAlpha = YES;
    NSString *domain = saveSettings;
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:domain];
    NSData *colorData = [defaults objectForKey:@"kBackgroundColor"];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:colorData error:nil];
    [unarchiver setRequiresSecureCoding:NO];
    UIColor *color = [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    self.selectedColor = color;
}

- (void)coloursView {
    self.view.backgroundColor = UIColor.secondarySystemBackgroundColor;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self coloursView];
}

@end

@implementation ColourOptionsController(Privates)

- (void)save {
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:self.selectedColor requiringSecureCoding:nil error:nil];
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:saveSettings];
    [defaults setObject:colorData forKey:@"kBackgroundColor"];
    [defaults synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)center {
    pid_t pid;
    int status;
    const char* args[] = { "killall", "-9", "SpringBoard", NULL };
    posix_spawn(&pid, "/var/jb/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
    waitpid(pid, &status, WEXITED);
    
    NSString *domain = saveSettings;
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:domain];
    [defaults removeObjectForKey:@"kBackgroundColor"];
    [defaults synchronize];
}

- (void)closeButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
