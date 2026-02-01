User-1:
``````text
请教我云(我是云初学者,我没有钱也没有信用卡去启动免费的云套餐,但是朋友告诉我可以用aws-cli和localstack,我用的哥哥的电脑他自己装的debian),我希望类似codecademy那样的极小微代码项目每个小节,(一开始讲解然后是作业,对于作业请给我每一步要做什么风格就像codecademy一样,它的作业风格类似一个作业拆分成多个检查点每个检查点都有明确的指令指向去引导我完成,每个小节完成了我把作业给你检查,你不要一小节太多东西,我的水平很差可能接受不了,我们开始第一个小节, 什么时候毕业你下定论
``````
Model-1:
``````markdown
太棒了！欢迎来到 **“零成本云工程师”** 第一课。

我很喜欢你的朋友给你的建议。**LocalStack** 就像是一个安装在你哥哥电脑里的“模拟器”。真正的 AWS 云需要钱，而 LocalStack 是一个在本地运行的“假”云，但操作方式和真的一模一样。学会了它，以后你有了信用卡，无缝切换到真正的 AWS 只需要改一行配置。

既然你的水平是初学者，而且用的是 Debian (Linux)，我们甚至不需要鼠标，我们将主要在那个黑色的窗口（终端）里通过打字来指挥云。

不用担心，我会带你一步步走。我们这一小节的目标非常小，甚至还没到启动云服务，我们先要装好“方向盘”。

---

## 第 1 课：安装你的“方向盘” (AWS CLI)

### 🎓 概念讲解

**什么是 AWS CLI？**
想象一下，云是一台巨大的超级计算机。

* 你可以用鼠标在网页上点点点来控制它（这叫控制台）。
* 你也可以像黑客一样，敲一行代码控制它。这行代码工具就叫 **AWS CLI** (Command Line Interface)。

专业的云工程师都用 CLI，因为它快、酷，而且可以自动化。既然我们在 Debian 系统上，这正是我们的主场。

---

### 🛠️ 实战作业：配置环境

请打开你哥哥电脑上的 **Terminal (终端)**，通常是一个黑色的图标。

按照下面的**检查点 (Checkpoints)**，一步步操作。每完成一步，你就在心里打个勾。

#### ✅ Checkpoint 1: 检查 Python

LocalStack 是用 Python 写成的，我们需要确保电脑里有它。
在终端输入以下命令并回车：

```bash
python3 --version

```

> **预期结果：** 你应该看到类似 `Python 3.x.x` 的字样。如果没有，请告诉我。

#### ✅ Checkpoint 2: 安装 AWS CLI

我们需要安装这个工具来向云发送指令。在 Debian 上，我们用 `apt` 命令。
*(注意：这可能需要输入你哥哥电脑的密码)*
输入：

```bash
sudo apt update
sudo apt install awscli -y

```

安装完成后，验证是否安装成功：

```bash
aws --version

```

> **预期结果：** 屏幕应该显示类似 `aws-cli/1.x.x ...` 或 `aws-cli/2.x.x ...` 的版本号。

#### ✅ Checkpoint 3: 配置“假”身份

AWS CLI 默认会问你要账号密码。因为我们用的是 LocalStack（模拟器），我们可以随便填，但必须得填，否则 CLI 不让过。

输入以下命令：

```bash
aws configure

```

接下来它会连续问你四个问题，请完全按照下面的内容输入（**不要担心安全问题，因为我们在做假配置**）：

1. `AWS Access Key ID`: 输入 **test** 然后回车。
2. `AWS Secret Access Key`: 输入 **test** 然后回车。
3. `Default region name`: 输入 **us-east-1** 然后回车。
4. `Default output format`: 输入 **json** 然后回车。

---

### 📤 提交作业

恭喜！你刚刚完成了云工程师生涯的第一步配置。

请把以下两个命令的运行结果复制粘贴给我，我来检查你是否准备好进入下一节了：

1. `aws --version` 的输出结果。
2. `aws configure list` 的输出结果。

(等你提交后，我们再进行下一节：安装那个“模拟器”本身)
``````

---

User-2:
``````text

~
> python3 --version
Python 3.13.5

~
> aws --version
aws-cli/2.23.6 Python/3.13.5 Linux/6.12.63+deb13-amd64 source/x86_64.debian.13

~
> aws configure
AWS Access Key ID [None]: test
AWS Secret Access Key [None]: test
Default region name [None]: us-east-1
Default output format [None]: json

~ on aws (us-east-1) took 48s
>
``````
Model-2:
``````markdown
干得漂亮！作业满分通过。
看到 `aws --version` 显示 `Python 3.13.5`，这说明你的基础环境很新，非常好。而且你已经配置好了 `test` 凭证，你的“方向盘”已经装好了。

现在，我们要把“引擎”装进去。但是，为了不把你不小心把你哥哥的电脑系统搞乱（比如安装了一堆乱七八糟的软件），我们要先做一个**隔离区**。在 Python 的世界里，这叫“虚拟环境” (Virtual Environment)。

想象我们在你哥哥的电脑里放了一个独立的沙箱，我们在沙箱里怎么玩都不会影响外面的系统。

---

## 第 2 课：搭建沙箱与安装模拟器 (LocalStack)

### 🎓 概念讲解

1. **虚拟环境 (venv)**：给你的项目穿一件防护服。所有的工具都装在这里面。
2. **LocalStack CLI**：这是启动“假云”的启动器。
3. **Docker**：这是 LocalStack 赖以生存的底层引擎。如果说 LocalStack 是个软件，Docker 就是承载它的操作系统。我们需要确认你哥哥的电脑里有没有它。

---

### 🛠️ 实战作业：搭建环境

请继续在那个黑色窗口（终端）里操作。

#### ✅ Checkpoint 1: 创建你的专属文件夹

我们要把所有东西都放在一个地方。

```bash
mkdir cloud-study
cd cloud-study

```

*(解释：`mkdir` 是制造一个文件夹，`cd` 是走进这个文件夹)*

#### ✅ Checkpoint 2: 创建并进入“隔离沙箱”

这是最关键的一步，保护你哥哥的电脑环境。

```bash
python3 -m venv venv
source venv/bin/activate

```

> **注意：** 执行完第二句后，你的命令行前面应该多了一个 `(venv)` 的字样。这说明你已经进入沙箱了！以后每次学习前，都要确保看到这个标志。

#### ✅ Checkpoint 3: 安装 LocalStack

现在我们在沙箱里，可以大胆地安装软件了。

```bash
pip install localstack

```

等待安装进度条跑完。

#### ✅ Checkpoint 4: 检查引擎 (Docker)

LocalStack 必须依赖 Docker 才能运行。我们需要看看你哥哥有没有装它。

```bash
docker --version

```

---

### 📤 提交作业

请把这一小节的操作结果告诉我，特别是最后一步。
请复制粘贴以下三个信息：

1. 你是否看到了命令行前面有 `(venv)` 字样？(回答是/否)
2. `localstack --version` 的输出结果。
3. `docker --version` 的输出结果 (如果显示 command not found，也请如实告诉我，这很重要)。

(如果你有 Docker，下一节我们就启动云！如果没有，下一节我们要先装 Docker。)
``````

---

User-3:
``````text

~/cloud-study via py v3.13.5 (venv) on aws (us-east-1)
> localstack --version
LocalStack CLI 4.13.0

~/cloud-study via py v3.13.5 (venv) on aws (us-east-1)
> docker --version
Docker version 29.2.0, build 0b9d198

~/cloud-study via py v3.13.5 (venv) on aws (us-east-1)
>
``````
Model-3:
``````markdown
太棒了！你的环境简直完美。
Docker 已经就位，版本也很新；你也在 `(venv)` 沙箱里了。而且我看你的终端提示符 (`~/cloud-study via py v3.13.5...`) 显示你好像用了一些很酷的终端主题，看来你哥哥把电脑配置得很好。

现在，我们要点火启动了！

---

## 第 3 课：启动云端与第一个存储桶

### 🎓 概念讲解

1. **Docker 镜像 (Image)**：LocalStack 就像是一个巨大的压缩包，我们需要先把它从网上“拉”下来（这叫 Pull），然后在 Docker 里运行它。
2. **S3 (Simple Storage Service)**：这是我们要学的第一个云服务。别被名字吓到，把它想象成**“云端无限容量的硬盘”**或者就是一个**“超级文件夹”**。
3. **Endpoint URL (端点)**：这是本节最难的概念。
* 当你敲 `aws` 命令时，它默认会去连接亚马逊美国的服务器 (`aws.amazon.com`)。
* 但我们没有钱，我们要连自己电脑上的 LocalStack。
* 所以我们需要告诉命令：“嘿，别去美国，去连接 `http://localhost:4566` (这是 LocalStack 在你电脑上的门牌号)”。



---

### 🛠️ 实战作业：点火与存储

#### ✅ Checkpoint 1: 启动 LocalStack

我们要让云在后台运行。
输入：

```bash
localstack start -d

```

> **注意：** 第一次运行这个命令时，它会去下载大约几百 MB 的数据（Docker 镜像），可能会卡住一会儿，取决于你的网速。请耐心等待，直到它显示 `Ready.` 或者回到命令行提示符。
> *参数解释：`-d` (Detached) 意思是在后台静默运行，不占用你的打字窗口。*

#### ✅ Checkpoint 2: 检查云是否活了

确认它已经正常工作。
输入：

```bash
localstack status services

```

> **预期结果：** 你应该看到一张表，或者显示 `running` 的状态。只要没有报错说 "Connection refused"，就是成功了。

#### ✅ Checkpoint 3: 创建你的第一个“云文件夹” (S3 Bucket)

现在我们要用 AWS CLI 向这个假云发送指令。我们要创建一个叫 `my-wallet` 的存储桶（Bucket）。

**请仔细输入这行长命令（注意那个 url 参数）：**

```bash
aws --endpoint-url=http://localhost:4566 s3 mb s3://my-wallet

```

*(命令翻译：aws 工具 -> 目标地址是本地 -> s3 服务 -> make bucket (mb) -> 名字叫 my-wallet)*

#### ✅ Checkpoint 4: 确认文件夹已创建

我们问问云：“我现在有哪些桶？”

```bash
aws --endpoint-url=http://localhost:4566 s3 ls

```

---

### 📤 提交作业

这一步如果你成功了，你就正式成为“在云上运行过资源的人”了！

请把以下结果复制给我：

1. Checkpoint 3 的输出结果（通常会显示 `make_bucket: ...`）。
2. Checkpoint 4 的输出结果（应该显示出你刚刚创建的桶）。

(如果在第一步下载卡住了或者报错，请直接告诉我，我们来修。)
``````

---

User-4:
``````text

~/cloud-study via py v3.13.5 (venv) on aws (us-east-1)
> aws --endpoint=http://localhost:4566 s3 mb s3://my-wallet
make_bucket: my-wallet

~/cloud-study via py v3.13.5 (venv) on aws (us-east-1) took 2s
> aws --endpoint=http://localhost:4566 s3 ls
2026-01-31 13:48:47 my-wallet

~/cloud-study via py v3.13.5 (venv) on aws (us-east-1)
>
``````
Model-4:
``````markdown
太棒了！你成功了！🎉
你现在正式拥有了一个运行在你哥哥电脑里的“私有云存储”，而且你已经成功创建了你的第一个存储桶 `my-wallet`。

哪怕是很多入行的初学者，在这一步都会因为网络配置或者端口问题卡住，你一次就过了，非常有天赋！

现在我们要进行下一步。虽然你做到了，但你有没有发现每次都要打 `--endpoint-url=http://localhost:4566` 这串长长的尾巴非常麻烦？如果不小心打错一个字母，命令就会失败。

这一节，我们要干两件事：

1. 往你的桶里放点东西。
2. 安装一个“魔法工具”，让我们以后再也不用打那串长长的尾巴。

---

## 第 4 课：上传文件与安装“魔法工具”

### 🎓 概念讲解

1. **对象 (Object)**：在云存储(S3)里，文件不叫文件，叫“对象”。
2. **cp (Copy)**：这是 Linux 和 AWS 里通用的命令，意思是“复制”。我们要把本地的文件“复制”到云端。
3. **awslocal**：这是一个专门为 LocalStack 设计的小工具。它会自动帮你在后台加上 `http://localhost:4566`，这样你打命令时就感觉像在用真的 AWS 一样简洁。

---

### 🛠️ 实战作业

#### ✅ Checkpoint 1: 制作一个假文件

我们要先在本地造一个文件，用来测试上传。
输入以下命令：

```bash
echo "Hello Cloud!" > money.txt

```

*(解释：这句话的意思是，把 "Hello Cloud!" 这句话写入到 money.txt 这个文件里。如果文件不存在，它会自动创建。)*

#### ✅ Checkpoint 2: 把文件“扔”进云里

现在，把这个 `money.txt` 上传到你上一节建好的 `my-wallet` 桶里。
*(我们再最后忍受一次长命令)*

```bash
aws --endpoint-url=http://localhost:4566 s3 cp money.txt s3://my-wallet

```

> **注意：** 如果你上一节用 `--endpoint` 也能跑通，那很神奇（可能是新版特性），但标准写法是 `--endpoint-url`，建议养成标准习惯。

#### ✅ Checkpoint 3: 安装“魔法工具” (awslocal)

现在我们要解放双手了。请在你的沙箱里安装这个神器：

```bash
pip install awscli-local

```

#### ✅ Checkpoint 4: 见证魔法

安装好后，我们以后所有的 `aws` 命令都可以换成 `awslocal`，并且**再也不用**写 endpoint 那一长串了！

试着用新命令查看你的桶里有什么：

```bash
awslocal s3 ls s3://my-wallet

```

---

### 📤 提交作业

请把 Checkpoint 4 的输出结果复制给我。

> **预期结果：** 你应该能看到类似 `2026-01-31 ... money.txt` 的字样。这就证明你的文件已经稳稳地躺在“云端”了。

(如果这一步成功，下一节我们将学习如何在这个“云”里搭建一个极简的静态网站！)
``````

---

User-5:
``````text

~/cloud-study via py v3.13.5 (venv) on aws (us-east-1) took 29s
> awslocal s3 ls s3://my-wallet
2026-01-31 13:58:49         13 money.txt

~/cloud-study via py v3.13.5 (venv) on aws (us-east-1)
>
``````
Model-5:
``````markdown
太棒了！你的进度非常快，而且 `awslocal` 已经完全工作正常。现在的你，打起命令来应该感觉轻松多了吧？

接下来我们要玩个大的。我们将要把你的这个“云盘”变成一个**网站服务器**。

---

## 第 5 课：把存储桶变成网站 (Static Website)

### 🎓 概念讲解

1. **静态网站 (Static Website)**：这是最古老也是最快的一种网站。它只包含纯展示的内容（HTML），就像一张贴在公告栏上的海报，每个人看到的都是一样的。
2. **S3 网站托管**：S3 有个神奇的功能，只要你开启它，你的存储桶就会变成一个网站服务器，外界就可以通过网址访问里面的文件了。
3. **curl**：这是一个命令行版的“浏览器”。它没有图形界面，但是可以帮我们抓取网页的内容。

---

### 🛠️ 实战作业：上线你的第一个网页

#### ✅ Checkpoint 1: 编写网页代码

虽然我们不教写网页，但我们需要一个极其简单的页面。
在终端输入：

```bash
echo "<h1>Hello from LocalStack!</h1>" > index.html

```

*(解释：这行代码创建了一个包含标题的 HTML 文件)*

#### ✅ Checkpoint 2: 创建一个新的桶

我们为了区分刚才的钱包，新建一个专门放网站的桶，叫 `my-site`。

```bash
awslocal s3 mb s3://my-site

```

#### ✅ Checkpoint 3: 开启“网站模式”

这是最关键的一步。我们要告诉云：“嘿，这个桶不仅仅是用来存文件的，它是用来做网站的，首页是 `index.html`。”

```bash
awslocal s3 website s3://my-site --index-document index.html

```

*(如果没有报错，通常不会有任何输出，这就是好消息)*

#### ✅ Checkpoint 4: 上传网页

把刚才写的 `index.html` 上传进去。

```bash
awslocal s3 cp index.html s3://my-site

```

#### ✅ Checkpoint 5: 访问你的网站！

激动人心的时刻到了。
在真正的 AWS 里，你会得到一个很长的网址。在 LocalStack 里，我们的网址是本地的。
我们用 `curl` 这个命令行浏览器来访问它：

```bash
curl http://my-site.s3-website.us-east-1.localhost.localstack.cloud:4566/

```

> **如果上面的命令太长报错或者无法解析**，请尝试这个备用命令（LocalStack 的不同版本有时候网址规则不同）：
> `curl http://localhost:4566/my-site/index.html`

---

### 📤 提交作业

请把 **Checkpoint 5** 的输出结果复制给我。

> **预期结果：** 你应该会在那个黑框框里看到这行代码被“吐”了出来：
> `<h1>Hello from LocalStack!</h1>`

如果你看到了这句话，恭喜你，你已经成功部署了一个网站！
(如果成功，下一节我们来清理战场，学习如何“销毁”资源，这是云工程师省钱的关键！)
``````

---

User-6:
``````text

~/cloud-study via py v3.13.5 (venv) on aws (us-east-1)
> curl http://localhost:4566/my-site/index.html
<h1>Hello from LocalStack!</h1>

~/cloud-study via py v3.13.5 (venv) on aws (us-east-1)
>

``````
Model-6:
``````markdown
恭喜！看到那行 `<h1>Hello from LocalStack!</h1>`，意味着你已经成功完成了一次完整的云端部署。

在真实的 AWS 世界里，你刚才开启的每一秒钟都在计费。虽然 LocalStack 是免费的，但**“随手关灯（清理资源）”**是云工程师最重要的素养之一。如果不清理，你的信用卡账单可能会像坐火箭一样起飞。

这也是我们 Level 1 的最后一课：**销毁**。

---

## 第 6 课：清理战场 (销毁资源)

### 🎓 概念讲解

1. **RB (Remove Bucket)**：这是删除存储桶的命令。
2. **非空保护**：这是云厂商为了防止你手滑误删数据做的一个机制。如果一个桶里还有文件，云是不允许你直接把桶删掉的。你必须先清空文件，再删桶。

---

### 🛠️ 实战作业：有始有终

#### ✅ Checkpoint 1: 尝试暴力删除 (并观察失败)

我们要先故意犯个错，看看云是怎么保护数据的。
尝试直接删除 `my-site` 这个桶：

```bash
awslocal s3 rb s3://my-site

```

> **预期结果：** 你应该会看到一个报错，包含 `BucketNotEmpty` 的字样。这是正常的！

#### ✅ Checkpoint 2: 清空文件

既然它嫌桶不空，那我们就把里面的 `index.html` 删掉。
使用 `rm` (remove) 命令：

```bash
awslocal s3 rm s3://my-site/index.html

```

#### ✅ Checkpoint 3: 再次删除桶

现在桶是空的了，再次尝试删除：

```bash
awslocal s3 rb s3://my-site

```

> **预期结果：** 这次应该会显示 `remove_bucket: my-site`。

#### ✅ Checkpoint 4: 最终核查

确认一下它真的消失了。

```bash
awslocal s3 ls

```

> **预期结果：** 你应该只看得到 `my-wallet` (那个钱包桶还在)，但看不到 `my-site` 了。

---

### 🎓 毕业典礼：Level 1 结业

等你提交这最后一次作业（Checkpoint 4 的输出），我就正式宣布你 **Level 1 毕业**。

**请提交：**

1. Checkpoint 1 的报错信息（这很重要，我想确认你看到了那个错误）。
2. Checkpoint 4 的最终列表。

提交后，我会给你做一个简短的总结，并为你颁发这一阶段的“云工程师徽章”。我们就可以结束今天的课程，让你休息一下了！
``````

---

User-7:
``````text
``````
Model-7:
``````markdown
``````

---

User-8:
``````text
``````
Model-8:
``````markdown
``````

---

User-9:
``````text
``````
Model-9:
``````markdown
``````

---

User-10:
``````text
``````
Model-10:
``````markdown
``````
